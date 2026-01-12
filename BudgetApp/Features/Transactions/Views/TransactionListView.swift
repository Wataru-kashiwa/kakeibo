import SwiftUI

/// 取引一覧画面
struct TransactionListView: View {
    @ObservedObject var viewModel: TransactionListViewModel
    @State private var showingDeleteConfirmation = false
    @State private var transactionToDelete: Transaction?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.transactions.isEmpty {
                    ProgressView("読み込み中...")
                } else if viewModel.transactions.isEmpty {
                    emptyStateView
                } else {
                    transactionListView
                }
            }
            .navigationTitle("取引")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable {
                await viewModel.loadTransactions()
            }
            .task {
                await viewModel.loadTransactions()
            }
            .sheet(isPresented: $viewModel.showingAddSheet) {
                TransactionEditView(
                    viewModel: TransactionEditViewModel(
                        addTransactionUseCase: AppContainer.shared.addTransactionUseCase,
                        updateTransactionUseCase: AppContainer.shared.updateTransactionUseCase
                    )
                ) {
                    Task {
                        await viewModel.loadTransactions()
                    }
                }
            }
            .sheet(item: $viewModel.editingTransaction) { transaction in
                TransactionEditView(
                    viewModel: TransactionEditViewModel(
                        transaction: transaction,
                        addTransactionUseCase: AppContainer.shared.addTransactionUseCase,
                        updateTransactionUseCase: AppContainer.shared.updateTransactionUseCase
                    )
                ) {
                    Task {
                        await viewModel.loadTransactions()
                    }
                }
            }
            .alert("エラー", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .confirmationDialog(
                "この取引を削除しますか？",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("削除", role: .destructive) {
                    if let transaction = transactionToDelete {
                        Task {
                            await viewModel.deleteTransaction(transaction)
                        }
                    }
                }
                Button("キャンセル", role: .cancel) {}
            }
        }
    }

    /// 空状態のビュー
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("取引がありません")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("右上の＋ボタンまたは\n他のアプリから共有して追加できます")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    /// 取引リストビュー
    private var transactionListView: some View {
        List {
            // 今月の合計セクション
            Section {
                HStack {
                    Text("今月の支出")
                    Spacer()
                    Text(viewModel.currentMonthTotal.toJPYString())
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }

            // 日付ごとの取引セクション
            ForEach(viewModel.groupedTransactions, id: \.date) { group in
                Section {
                    ForEach(group.transactions) { transaction in
                        TransactionRowView(transaction: transaction)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.editingTransaction = transaction
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    transactionToDelete = transaction
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    Text(group.date.toJapaneseString())
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

/// 取引行ビュー
struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            // カテゴリアイコン
            if let categoryName = transaction.categoryName,
               let category = Category.presets.first(where: { $0.name == categoryName }) {
                Image(systemName: category.iconName)
                    .foregroundColor(.accentColor)
                    .frame(width: 30)
            } else {
                Image(systemName: "tag")
                    .foregroundColor(.secondary)
                    .frame(width: 30)
            }

            VStack(alignment: .leading, spacing: 4) {
                // カテゴリ名またはメモ
                if let categoryName = transaction.categoryName {
                    Text(categoryName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                } else if let memo = transaction.memo, !memo.isEmpty {
                    Text(memo)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                } else {
                    Text("未分類")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // メモ（カテゴリがある場合のみ表示）
                if transaction.categoryName != nil,
                   let memo = transaction.memo,
                   !memo.isEmpty {
                    Text(memo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                // Share Extension経由のマーク
                if transaction.source == .shareExtension {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text("共有から追加")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
            }

            Spacer()

            // 金額
            Text(transaction.amount.toJPYString())
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TransactionListView(
        viewModel: TransactionListViewModel(
            getTransactionsUseCase: GetTransactionsUseCase(
                repository: LocalTransactionRepository()
            ),
            deleteTransactionUseCase: DeleteTransactionUseCase(
                repository: LocalTransactionRepository()
            )
        )
    )
}

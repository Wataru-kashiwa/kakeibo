import SwiftUI

/// 取引編集画面
struct TransactionEditView: View {
    @ObservedObject var viewModel: TransactionEditViewModel
    @Environment(\.dismiss) private var dismiss

    /// 保存完了時のコールバック
    var onSave: (() -> Void)?

    var body: some View {
        NavigationStack {
            Form {
                // 金額入力セクション
                Section {
                    HStack {
                        Text("¥")
                            .foregroundColor(.secondary)
                        TextField("金額（任意）", text: $viewModel.amountText)
                            .keyboardType(.numberPad)
                    }
                } header: {
                    Text("金額")
                }

                // 日付選択セクション
                Section {
                    DatePicker(
                        "日付",
                        selection: $viewModel.date,
                        displayedComponents: .date
                    )
                    .environment(\.locale, Locale(identifier: "ja_JP"))
                } header: {
                    Text("日付")
                }

                // カテゴリ選択セクション
                Section {
                    Picker("カテゴリ", selection: $viewModel.selectedCategoryName) {
                        Text("未分類").tag(nil as String?)
                        ForEach(viewModel.categories) { category in
                            Label(category.name, systemImage: category.iconName)
                                .tag(category.name as String?)
                        }
                    }
                } header: {
                    Text("カテゴリ")
                }

                // メモ入力セクション
                Section {
                    TextEditor(text: $viewModel.memo)
                        .frame(minHeight: 100)
                } header: {
                    Text("メモ")
                }

                // エラーメッセージ
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .disabled(viewModel.isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            let success = await viewModel.save()
                            if success {
                                onSave?()
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .overlay {
                if viewModel.isSaving {
                    ProgressView("保存中...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .interactiveDismissDisabled(viewModel.isSaving)
        }
    }
}

#Preview("新規作成") {
    TransactionEditView(
        viewModel: TransactionEditViewModel(
            addTransactionUseCase: AddTransactionUseCase(
                repository: LocalTransactionRepository()
            ),
            updateTransactionUseCase: UpdateTransactionUseCase(
                repository: LocalTransactionRepository()
            )
        )
    )
}

#Preview("編集") {
    TransactionEditView(
        viewModel: TransactionEditViewModel(
            transaction: Transaction(
                amount: 1500,
                date: Date(),
                memo: "ランチ",
                categoryName: "食費"
            ),
            addTransactionUseCase: AddTransactionUseCase(
                repository: LocalTransactionRepository()
            ),
            updateTransactionUseCase: UpdateTransactionUseCase(
                repository: LocalTransactionRepository()
            )
        )
    )
}

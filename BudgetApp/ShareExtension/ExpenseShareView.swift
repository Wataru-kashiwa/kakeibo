import SwiftUI

/// Share Extension用の支出入力フォーム
struct ExpenseShareView: View {
    @ObservedObject var viewModel: ExpenseShareViewModel

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
                } footer: {
                    if !viewModel.sharedText.isEmpty {
                        Text("共有されたテキストが入力されています")
                            .font(.caption)
                    }
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
            .navigationTitle("支出を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        viewModel.cancel()
                    }
                    .disabled(viewModel.isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            await viewModel.save()
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
        }
    }
}

#Preview {
    ExpenseShareView(
        viewModel: ExpenseShareViewModel(
            sharedText: "テスト ¥1,234",
            onSave: {},
            onCancel: {}
        )
    )
}

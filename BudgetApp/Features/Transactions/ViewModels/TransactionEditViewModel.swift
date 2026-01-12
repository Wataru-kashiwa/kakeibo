import Foundation
import Combine

/// 取引編集画面のViewModel
@MainActor
final class TransactionEditViewModel: ObservableObject {
    // MARK: - Published Properties

    /// 金額入力（文字列）
    @Published var amountText: String = ""
    /// 選択された日付
    @Published var date: Date = Date()
    /// 選択されたカテゴリ名
    @Published var selectedCategoryName: String?
    /// メモ入力
    @Published var memo: String = ""
    /// 保存処理中フラグ
    @Published var isSaving: Bool = false
    /// エラーメッセージ
    @Published var errorMessage: String?

    // MARK: - Properties

    /// 編集モードかどうか
    let isEditMode: Bool
    /// 編集対象の取引
    private let existingTransaction: Transaction?
    /// 利用可能なカテゴリ一覧
    let categories: [Category] = Category.presets
    /// 取引追加ユースケース
    private let addTransactionUseCase: AddTransactionUseCase
    /// 取引更新ユースケース
    private let updateTransactionUseCase: UpdateTransactionUseCase

    // MARK: - Computed Properties

    /// ナビゲーションタイトル
    var navigationTitle: String {
        isEditMode ? "取引を編集" : "取引を追加"
    }

    /// 入力された金額（Decimal）
    var amount: Decimal? {
        guard !amountText.isEmpty else { return nil }
        let cleanedText = amountText
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "¥", with: "")
            .replacingOccurrences(of: "￥", with: "")
            .replacingOccurrences(of: "円", with: "")
            .trimmingCharacters(in: .whitespaces)
        return Decimal(string: cleanedText)
    }

    // MARK: - Initialization

    /// 初期化（新規作成モード）
    /// - Parameters:
    ///   - addTransactionUseCase: 取引追加ユースケース
    ///   - updateTransactionUseCase: 取引更新ユースケース
    init(
        addTransactionUseCase: AddTransactionUseCase,
        updateTransactionUseCase: UpdateTransactionUseCase
    ) {
        self.isEditMode = false
        self.existingTransaction = nil
        self.addTransactionUseCase = addTransactionUseCase
        self.updateTransactionUseCase = updateTransactionUseCase
    }

    /// 初期化（編集モード）
    /// - Parameters:
    ///   - transaction: 編集対象の取引
    ///   - addTransactionUseCase: 取引追加ユースケース
    ///   - updateTransactionUseCase: 取引更新ユースケース
    init(
        transaction: Transaction,
        addTransactionUseCase: AddTransactionUseCase,
        updateTransactionUseCase: UpdateTransactionUseCase
    ) {
        self.isEditMode = true
        self.existingTransaction = transaction
        self.addTransactionUseCase = addTransactionUseCase
        self.updateTransactionUseCase = updateTransactionUseCase

        // 既存データで初期化
        if let amount = transaction.amount {
            self.amountText = amount.toFormattedString()
        }
        self.date = transaction.date
        self.selectedCategoryName = transaction.categoryName
        self.memo = transaction.memo ?? ""
    }

    // MARK: - Methods

    /// 取引を保存する
    /// - Returns: 保存成功したかどうか
    func save() async -> Bool {
        isSaving = true
        errorMessage = nil

        do {
            if isEditMode, let existing = existingTransaction {
                // 更新
                var updatedTransaction = existing
                updatedTransaction.amount = amount
                updatedTransaction.date = date
                updatedTransaction.categoryName = selectedCategoryName
                updatedTransaction.memo = memo.isEmpty ? nil : memo
                _ = try await updateTransactionUseCase.execute(updatedTransaction)
            } else {
                // 新規作成
                _ = try await addTransactionUseCase.execute(
                    amount: amount,
                    date: date,
                    categoryName: selectedCategoryName,
                    memo: memo.isEmpty ? nil : memo,
                    sourceText: nil,
                    source: .app
                )
            }
            isSaving = false
            return true
        } catch {
            errorMessage = "保存に失敗しました: \(error.localizedDescription)"
            isSaving = false
            return false
        }
    }
}

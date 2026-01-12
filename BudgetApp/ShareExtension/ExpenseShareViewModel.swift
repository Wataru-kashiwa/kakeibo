import Foundation
import Combine

/// Share Extension用のViewModel
/// 取引入力フォームの状態管理と保存処理を担う
@MainActor
final class ExpenseShareViewModel: ObservableObject {
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

    /// 共有元のテキスト
    let sharedText: String
    /// 利用可能なカテゴリ一覧
    let categories: [Category] = Category.presets
    /// 保存完了時のコールバック
    private let onSave: () -> Void
    /// キャンセル時のコールバック
    private let onCancel: () -> Void
    /// 取引追加ユースケース
    private let addTransactionUseCase: AddTransactionUseCase
    /// パーサー
    private let parser: TransactionParser

    // MARK: - Computed Properties

    /// 入力された金額（Decimal）
    var amount: Decimal? {
        guard !amountText.isEmpty else { return nil }
        // カンマや円記号を除去
        let cleanedText = amountText
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "¥", with: "")
            .replacingOccurrences(of: "￥", with: "")
            .replacingOccurrences(of: "円", with: "")
            .trimmingCharacters(in: .whitespaces)
        return Decimal(string: cleanedText)
    }

    // MARK: - Initialization

    /// 初期化
    /// - Parameters:
    ///   - sharedText: 共有されたテキスト
    ///   - onSave: 保存完了時のコールバック
    ///   - onCancel: キャンセル時のコールバック
    ///   - repository: 取引リポジトリ（デフォルト：LocalTransactionRepository）
    init(
        sharedText: String,
        onSave: @escaping () -> Void,
        onCancel: @escaping () -> Void,
        repository: TransactionRepositoryProtocol = LocalTransactionRepository()
    ) {
        self.sharedText = sharedText
        self.onSave = onSave
        self.onCancel = onCancel
        self.addTransactionUseCase = AddTransactionUseCase(repository: repository)
        self.parser = RegexParser()

        // 共有テキストをメモに設定
        self.memo = sharedText

        // 自動抽出を試みる
        Task {
            await parseSharedText()
        }
    }

    // MARK: - Methods

    /// 共有テキストを解析して自動入力する
    private func parseSharedText() async {
        guard !sharedText.isEmpty else { return }

        let result = await parser.parse(sharedText)

        if let extractedAmount = result.amount {
            amountText = extractedAmount.toFormattedString()
        }
    }

    /// 取引を保存する
    func save() async {
        isSaving = true
        errorMessage = nil

        do {
            _ = try await addTransactionUseCase.execute(
                amount: amount,
                date: date,
                categoryName: selectedCategoryName,
                memo: memo.isEmpty ? nil : memo,
                sourceText: sharedText.isEmpty ? nil : sharedText,
                source: .shareExtension
            )
            onSave()
        } catch {
            errorMessage = "保存に失敗しました: \(error.localizedDescription)"
            isSaving = false
        }
    }

    /// キャンセル処理
    func cancel() {
        onCancel()
    }
}

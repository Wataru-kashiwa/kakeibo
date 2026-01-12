import Foundation

/// 取引追加のユースケース
/// 新規取引をリポジトリに保存する
final class AddTransactionUseCase {
    private let repository: TransactionRepositoryProtocol

    /// 初期化
    /// - Parameter repository: 取引リポジトリ
    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    /// 取引を追加する
    /// - Parameters:
    ///   - amount: 金額（nil可）
    ///   - date: 取引日
    ///   - categoryName: カテゴリ名（nil可）
    ///   - memo: メモ（nil可）
    ///   - sourceText: 共有元テキスト（nil可）
    ///   - source: 登録元
    /// - Returns: 保存された取引
    /// - Throws: 保存に失敗した場合のエラー
    func execute(
        amount: Decimal?,
        date: Date,
        categoryName: String?,
        memo: String?,
        sourceText: String?,
        source: TransactionSource = .app
    ) async throws -> Transaction {
        let transaction = Transaction(
            amount: amount,
            date: date,
            memo: memo,
            categoryName: categoryName,
            sourceText: sourceText,
            source: source
        )
        return try await repository.save(transaction)
    }
}

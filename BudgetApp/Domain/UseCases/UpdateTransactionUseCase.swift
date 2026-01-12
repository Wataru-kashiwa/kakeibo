import Foundation

/// 取引更新のユースケース
/// 既存の取引を更新する
final class UpdateTransactionUseCase {
    private let repository: TransactionRepositoryProtocol

    /// 初期化
    /// - Parameter repository: 取引リポジトリ
    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    /// 取引を更新する
    /// - Parameter transaction: 更新する取引
    /// - Returns: 更新された取引
    /// - Throws: 更新に失敗した場合のエラー
    func execute(_ transaction: Transaction) async throws -> Transaction {
        var updatedTransaction = transaction
        updatedTransaction.updatedAt = Date()
        return try await repository.update(updatedTransaction)
    }
}

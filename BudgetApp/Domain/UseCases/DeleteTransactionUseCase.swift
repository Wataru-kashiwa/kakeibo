import Foundation

/// 取引削除のユースケース
/// 取引をリポジトリから削除する
final class DeleteTransactionUseCase {
    private let repository: TransactionRepositoryProtocol

    /// 初期化
    /// - Parameter repository: 取引リポジトリ
    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    /// 取引を削除する
    /// - Parameter id: 削除する取引のID
    /// - Throws: 削除に失敗した場合のエラー
    func execute(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}

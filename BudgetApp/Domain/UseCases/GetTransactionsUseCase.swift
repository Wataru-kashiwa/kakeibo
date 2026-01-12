import Foundation

/// 取引一覧取得のユースケース
/// 条件に合致する取引を取得する
final class GetTransactionsUseCase {
    private let repository: TransactionRepositoryProtocol

    /// 初期化
    /// - Parameter repository: 取引リポジトリ
    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    /// 条件に合致する取引一覧を取得する
    /// - Parameters:
    ///   - startDate: 開始日（nil：制限なし）
    ///   - endDate: 終了日（nil：制限なし）
    ///   - categoryName: カテゴリ名（nil：全カテゴリ）
    /// - Returns: 取引一覧（日付降順）
    /// - Throws: 取得に失敗した場合のエラー
    func execute(
        startDate: Date? = nil,
        endDate: Date? = nil,
        categoryName: String? = nil
    ) async throws -> [Transaction] {
        return try await repository.fetchAll(
            startDate: startDate,
            endDate: endDate,
            categoryName: categoryName
        )
    }

    /// IDで取引を取得する
    /// - Parameter id: 取引ID
    /// - Returns: 取引（存在しない場合はnil）
    /// - Throws: 取得に失敗した場合のエラー
    func execute(id: UUID) async throws -> Transaction? {
        return try await repository.fetch(id: id)
    }
}

import Foundation

/// 取引データの永続化を担うRepositoryのプロトコル
/// Data層で具体的な実装を行う
protocol TransactionRepositoryProtocol {
    /// 取引を保存する
    /// - Parameter transaction: 保存する取引
    /// - Returns: 保存された取引
    /// - Throws: 保存に失敗した場合のエラー
    func save(_ transaction: Transaction) async throws -> Transaction

    /// 取引を更新する
    /// - Parameter transaction: 更新する取引
    /// - Returns: 更新された取引
    /// - Throws: 更新に失敗した場合のエラー
    func update(_ transaction: Transaction) async throws -> Transaction

    /// 取引を削除する
    /// - Parameter id: 削除する取引のID
    /// - Throws: 削除に失敗した場合のエラー
    func delete(id: UUID) async throws

    /// IDで取引を取得する
    /// - Parameter id: 取引ID
    /// - Returns: 取引（存在しない場合はnil）
    func fetch(id: UUID) async throws -> Transaction?

    /// 条件に合致する取引一覧を取得する
    /// - Parameters:
    ///   - startDate: 開始日（nil：制限なし）
    ///   - endDate: 終了日（nil：制限なし）
    ///   - categoryName: カテゴリ名（nil：全カテゴリ）
    /// - Returns: 取引一覧（日付降順）
    func fetchAll(
        startDate: Date?,
        endDate: Date?,
        categoryName: String?
    ) async throws -> [Transaction]

    /// 指定期間・カテゴリの支出合計を計算する
    /// - Parameters:
    ///   - startDate: 開始日
    ///   - endDate: 終了日
    ///   - categoryName: カテゴリ名（nil：全カテゴリ）
    /// - Returns: 支出合計
    func calculateTotal(
        startDate: Date,
        endDate: Date,
        categoryName: String?
    ) async throws -> Decimal
}

/// Repositoryエラー
enum RepositoryError: Error, LocalizedError {
    case saveFailed(underlying: Error)
    case updateFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    case notFound

    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "保存に失敗しました: \(error.localizedDescription)"
        case .updateFailed(let error):
            return "更新に失敗しました: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "削除に失敗しました: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "取得に失敗しました: \(error.localizedDescription)"
        case .notFound:
            return "データが見つかりません"
        }
    }
}

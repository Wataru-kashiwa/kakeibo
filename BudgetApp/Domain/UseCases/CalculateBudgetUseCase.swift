import Foundation

/// 予算計算のユースケース（Phase 2で使用）
/// 予算の進捗状況を計算する
final class CalculateBudgetUseCase {
    private let repository: TransactionRepositoryProtocol

    /// 初期化
    /// - Parameter repository: 取引リポジトリ
    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    /// 予算の進捗状況を計算する
    /// - Parameter budget: 対象予算
    /// - Returns: 予算進捗状況
    /// - Throws: 計算に失敗した場合のエラー
    func execute(budget: Budget) async throws -> BudgetProgress {
        let currentSpending = try await repository.calculateTotal(
            startDate: budget.startDate,
            endDate: budget.endDate,
            categoryName: budget.categoryName
        )
        return BudgetProgress(budget: budget, currentSpending: currentSpending)
    }
}

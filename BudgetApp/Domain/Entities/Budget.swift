import Foundation

/// 予算データを表すドメインEntity（Phase 2で使用）
struct Budget: Identifiable, Equatable {
    /// 一意識別子
    let id: UUID
    /// カテゴリ名（nil：全体予算）
    var categoryName: String?
    /// 予算金額
    var amount: Decimal
    /// 予算期間タイプ
    var period: BudgetPeriod
    /// 開始日
    var startDate: Date
    /// 終了日
    var endDate: Date

    /// 初期化
    /// - Parameters:
    ///   - id: 一意識別子
    ///   - categoryName: カテゴリ名
    ///   - amount: 予算金額
    ///   - period: 予算期間タイプ
    ///   - startDate: 開始日
    ///   - endDate: 終了日
    init(
        id: UUID = UUID(),
        categoryName: String? = nil,
        amount: Decimal,
        period: BudgetPeriod = .monthly,
        startDate: Date,
        endDate: Date
    ) {
        self.id = id
        self.categoryName = categoryName
        self.amount = amount
        self.period = period
        self.startDate = startDate
        self.endDate = endDate
    }
}

/// 予算期間タイプ
enum BudgetPeriod: String, Codable {
    case weekly = "weekly"
    case monthly = "monthly"
    case custom = "custom"
}

/// 予算の進捗状況
struct BudgetProgress: Equatable {
    /// 対象予算
    let budget: Budget
    /// 現在の支出合計
    let currentSpending: Decimal
    /// 達成率（0.0〜1.0+）
    var progressRate: Double {
        guard budget.amount > 0 else { return 0 }
        return NSDecimalNumber(decimal: currentSpending)
            .dividing(by: NSDecimalNumber(decimal: budget.amount))
            .doubleValue
    }
    /// 残り予算
    var remaining: Decimal {
        budget.amount - currentSpending
    }
    /// 予算超過フラグ
    var isOverBudget: Bool {
        currentSpending > budget.amount
    }
}

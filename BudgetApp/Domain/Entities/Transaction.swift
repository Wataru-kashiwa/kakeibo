import Foundation

/// 取引データを表すドメインEntity
/// Core Dataのマネージドオブジェクトとは独立した純粋なデータ構造
struct Transaction: Identifiable, Equatable {
    /// 一意識別子
    let id: UUID
    /// 金額（nil可：未入力の場合）
    var amount: Decimal?
    /// 取引日
    var date: Date
    /// メモ（nil可）
    var memo: String?
    /// カテゴリ名（nil可：未分類の場合）
    var categoryName: String?
    /// 共有元のテキスト（Share Extensionから受け取ったテキスト）
    var sourceText: String?
    /// データの登録元
    var source: TransactionSource
    /// プライベート取引フラグ（家族共有時に使用）
    var isPrivate: Bool
    /// 作成日時
    let createdAt: Date
    /// 更新日時
    var updatedAt: Date

    /// 初期化
    /// - Parameters:
    ///   - id: 一意識別子（デフォルト：新規UUID）
    ///   - amount: 金額
    ///   - date: 取引日（デフォルト：現在日時）
    ///   - memo: メモ
    ///   - categoryName: カテゴリ名
    ///   - sourceText: 共有元テキスト
    ///   - source: 登録元
    ///   - isPrivate: プライベートフラグ
    ///   - createdAt: 作成日時（デフォルト：現在日時）
    ///   - updatedAt: 更新日時（デフォルト：現在日時）
    init(
        id: UUID = UUID(),
        amount: Decimal? = nil,
        date: Date = Date(),
        memo: String? = nil,
        categoryName: String? = nil,
        sourceText: String? = nil,
        source: TransactionSource = .app,
        isPrivate: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.memo = memo
        self.categoryName = categoryName
        self.sourceText = sourceText
        self.source = source
        self.isPrivate = isPrivate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// 取引の登録元を表す列挙型
enum TransactionSource: String, Codable {
    /// メインアプリから登録
    case app = "app"
    /// Share Extensionから登録
    case shareExtension = "share_extension"
}

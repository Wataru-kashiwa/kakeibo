import Foundation

/// カテゴリを表すドメインEntity
struct Category: Identifiable, Equatable, Hashable {
    /// 一意識別子
    let id: UUID
    /// カテゴリ名
    var name: String
    /// アイコン名（SF Symbols）
    var iconName: String
    /// 表示順序
    var displayOrder: Int

    /// 初期化
    /// - Parameters:
    ///   - id: 一意識別子（デフォルト：新規UUID）
    ///   - name: カテゴリ名
    ///   - iconName: アイコン名
    ///   - displayOrder: 表示順序
    init(
        id: UUID = UUID(),
        name: String,
        iconName: String = "tag",
        displayOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.displayOrder = displayOrder
    }
}

/// プリセットカテゴリの定義
extension Category {
    /// デフォルトのカテゴリ一覧を返す
    static var presets: [Category] {
        [
            Category(name: "食費", iconName: "fork.knife", displayOrder: 0),
            Category(name: "交通費", iconName: "car.fill", displayOrder: 1),
            Category(name: "娯楽", iconName: "gamecontroller.fill", displayOrder: 2),
            Category(name: "日用品", iconName: "cart.fill", displayOrder: 3),
            Category(name: "光熱費", iconName: "bolt.fill", displayOrder: 4),
            Category(name: "通信費", iconName: "phone.fill", displayOrder: 5),
            Category(name: "医療費", iconName: "cross.case.fill", displayOrder: 6),
            Category(name: "その他", iconName: "ellipsis.circle.fill", displayOrder: 7)
        ]
    }
}

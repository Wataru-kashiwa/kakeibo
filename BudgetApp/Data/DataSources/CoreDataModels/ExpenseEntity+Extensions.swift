import CoreData
import Foundation

/// ExpenseEntityの拡張
/// ドメインEntityとCore Dataマネージドオブジェクト間の変換を行う
extension ExpenseEntity {
    /// TransactionドメインEntityに変換する
    /// - Returns: Transaction Entity
    func toDomain() -> Transaction {
        Transaction(
            id: id ?? UUID(),
            amount: amount as Decimal?,
            date: date ?? Date(),
            memo: memo,
            categoryName: categoryName,
            sourceText: sourceText,
            source: TransactionSource(rawValue: source ?? "app") ?? .app,
            isPrivate: isPrivate,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }

    /// TransactionドメインEntityから値を設定する
    /// - Parameter transaction: 元となるTransaction
    func update(from transaction: Transaction) {
        self.id = transaction.id
        self.amount = transaction.amount as NSDecimalNumber?
        self.date = transaction.date
        self.memo = transaction.memo
        self.categoryName = transaction.categoryName
        self.sourceText = transaction.sourceText
        self.source = transaction.source.rawValue
        self.isPrivate = transaction.isPrivate
        self.createdAt = transaction.createdAt
        self.updatedAt = transaction.updatedAt
    }

    /// 新規ExpenseEntityを作成しTransactionから値を設定する
    /// - Parameters:
    ///   - context: NSManagedObjectContext
    ///   - transaction: 元となるTransaction
    /// - Returns: 新規ExpenseEntity
    static func create(
        in context: NSManagedObjectContext,
        from transaction: Transaction
    ) -> ExpenseEntity {
        let entity = ExpenseEntity(context: context)
        entity.update(from: transaction)
        return entity
    }
}

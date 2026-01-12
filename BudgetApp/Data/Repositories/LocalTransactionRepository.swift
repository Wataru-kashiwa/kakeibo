import CoreData
import Foundation

/// Core Dataを使用した取引リポジトリの実装
final class LocalTransactionRepository: TransactionRepositoryProtocol {
    private let coreDataManager: CoreDataManager

    /// 初期化
    /// - Parameter coreDataManager: Core Dataマネージャー（デフォルト：shared）
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }

    /// 取引を保存する
    /// - Parameter transaction: 保存する取引
    /// - Returns: 保存された取引
    func save(_ transaction: Transaction) async throws -> Transaction {
        do {
            return try await coreDataManager.performBackgroundTask { context in
                _ = ExpenseEntity.create(in: context, from: transaction)
                return transaction
            }
        } catch {
            throw RepositoryError.saveFailed(underlying: error)
        }
    }

    /// 取引を更新する
    /// - Parameter transaction: 更新する取引
    /// - Returns: 更新された取引
    func update(_ transaction: Transaction) async throws -> Transaction {
        do {
            return try await coreDataManager.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
                fetchRequest.fetchLimit = 1

                guard let entity = try context.fetch(fetchRequest).first else {
                    throw RepositoryError.notFound
                }

                entity.update(from: transaction)
                return transaction
            }
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.updateFailed(underlying: error)
        }
    }

    /// 取引を削除する
    /// - Parameter id: 削除する取引のID
    func delete(id: UUID) async throws {
        do {
            try await coreDataManager.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                fetchRequest.fetchLimit = 1

                guard let entity = try context.fetch(fetchRequest).first else {
                    throw RepositoryError.notFound
                }

                context.delete(entity)
            }
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.deleteFailed(underlying: error)
        }
    }

    /// IDで取引を取得する
    /// - Parameter id: 取引ID
    /// - Returns: 取引（存在しない場合はnil）
    func fetch(id: UUID) async throws -> Transaction? {
        do {
            return try await coreDataManager.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                fetchRequest.fetchLimit = 1

                return try context.fetch(fetchRequest).first?.toDomain()
            }
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }

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
    ) async throws -> [Transaction] {
        do {
            return try await coreDataManager.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: false)
                ]
                // パフォーマンス最適化
                fetchRequest.fetchBatchSize = 20

                // 検索条件の構築
                var predicates: [NSPredicate] = []

                if let startDate = startDate {
                    predicates.append(NSPredicate(format: "date >= %@", startDate as NSDate))
                }
                if let endDate = endDate {
                    predicates.append(NSPredicate(format: "date <= %@", endDate as NSDate))
                }
                if let categoryName = categoryName {
                    predicates.append(NSPredicate(format: "categoryName == %@", categoryName))
                }

                if !predicates.isEmpty {
                    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                }

                let entities = try context.fetch(fetchRequest)
                return entities.map { $0.toDomain() }
            }
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }

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
    ) async throws -> Decimal {
        do {
            return try await coreDataManager.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()

                // 検索条件の構築
                var predicates: [NSPredicate] = [
                    NSPredicate(format: "date >= %@", startDate as NSDate),
                    NSPredicate(format: "date <= %@", endDate as NSDate),
                    NSPredicate(format: "amount != nil")
                ]

                if let categoryName = categoryName {
                    predicates.append(NSPredicate(format: "categoryName == %@", categoryName))
                }

                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

                let entities = try context.fetch(fetchRequest)
                return entities.compactMap { $0.amount as Decimal? }.reduce(0, +)
            }
        } catch {
            throw RepositoryError.fetchFailed(underlying: error)
        }
    }
}

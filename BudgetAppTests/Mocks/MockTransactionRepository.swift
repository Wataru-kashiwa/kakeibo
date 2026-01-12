import Foundation
@testable import BudgetApp

/// テスト用の取引リポジトリモック
final class MockTransactionRepository: TransactionRepositoryProtocol {
    /// 保存された取引を記録
    var savedTransactions: [Transaction] = []
    /// 更新された取引を記録
    var updatedTransactions: [Transaction] = []
    /// 削除されたIDを記録
    var deletedIds: [UUID] = []
    /// fetchAllの戻り値
    var transactionsToReturn: [Transaction] = []
    /// 発生させるエラー
    var errorToThrow: Error?

    func save(_ transaction: Transaction) async throws -> Transaction {
        if let error = errorToThrow {
            throw error
        }
        savedTransactions.append(transaction)
        transactionsToReturn.append(transaction)
        return transaction
    }

    func update(_ transaction: Transaction) async throws -> Transaction {
        if let error = errorToThrow {
            throw error
        }
        updatedTransactions.append(transaction)
        if let index = transactionsToReturn.firstIndex(where: { $0.id == transaction.id }) {
            transactionsToReturn[index] = transaction
        }
        return transaction
    }

    func delete(id: UUID) async throws {
        if let error = errorToThrow {
            throw error
        }
        deletedIds.append(id)
        transactionsToReturn.removeAll { $0.id == id }
    }

    func fetch(id: UUID) async throws -> Transaction? {
        if let error = errorToThrow {
            throw error
        }
        return transactionsToReturn.first { $0.id == id }
    }

    func fetchAll(
        startDate: Date?,
        endDate: Date?,
        categoryName: String?
    ) async throws -> [Transaction] {
        if let error = errorToThrow {
            throw error
        }
        var result = transactionsToReturn

        if let startDate = startDate {
            result = result.filter { $0.date >= startDate }
        }
        if let endDate = endDate {
            result = result.filter { $0.date <= endDate }
        }
        if let categoryName = categoryName {
            result = result.filter { $0.categoryName == categoryName }
        }

        return result.sorted { $0.date > $1.date }
    }

    func calculateTotal(
        startDate: Date,
        endDate: Date,
        categoryName: String?
    ) async throws -> Decimal {
        if let error = errorToThrow {
            throw error
        }
        var result = transactionsToReturn
            .filter { $0.date >= startDate && $0.date <= endDate }

        if let categoryName = categoryName {
            result = result.filter { $0.categoryName == categoryName }
        }

        return result.compactMap { $0.amount }.reduce(0, +)
    }

    /// モックをリセット
    func reset() {
        savedTransactions = []
        updatedTransactions = []
        deletedIds = []
        transactionsToReturn = []
        errorToThrow = nil
    }
}

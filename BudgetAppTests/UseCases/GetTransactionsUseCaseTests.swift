import XCTest
@testable import BudgetApp

/// GetTransactionsUseCaseの単体テスト
final class GetTransactionsUseCaseTests: XCTestCase {
    var sut: GetTransactionsUseCase!
    var mockRepository: MockTransactionRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockTransactionRepository()
        sut = GetTransactionsUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    /// 取引一覧が正常に取得できること
    func test_getTransactions_正常系() async throws {
        // Given
        let transactions = [
            Transaction(amount: 1000, date: Date(), categoryName: "食費"),
            Transaction(amount: 2000, date: Date(), categoryName: "交通費")
        ]
        mockRepository.transactionsToReturn = transactions

        // When
        let result = try await sut.execute()

        // Then
        XCTAssertEqual(result.count, 2)
    }

    /// カテゴリでフィルタリングできること
    func test_getTransactions_正常系_カテゴリフィルタ() async throws {
        // Given
        let transactions = [
            Transaction(amount: 1000, date: Date(), categoryName: "食費"),
            Transaction(amount: 2000, date: Date(), categoryName: "交通費"),
            Transaction(amount: 3000, date: Date(), categoryName: "食費")
        ]
        mockRepository.transactionsToReturn = transactions

        // When
        let result = try await sut.execute(categoryName: "食費")

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.categoryName == "食費" })
    }

    /// 日付範囲でフィルタリングできること
    func test_getTransactions_正常系_日付フィルタ() async throws {
        // Given
        let today = Date()
        let yesterday = today.addingDays(-1)
        let twoDaysAgo = today.addingDays(-2)

        let transactions = [
            Transaction(amount: 1000, date: today, categoryName: "食費"),
            Transaction(amount: 2000, date: yesterday, categoryName: "食費"),
            Transaction(amount: 3000, date: twoDaysAgo, categoryName: "食費")
        ]
        mockRepository.transactionsToReturn = transactions

        // When
        let result = try await sut.execute(startDate: yesterday, endDate: today)

        // Then
        XCTAssertEqual(result.count, 2)
    }

    /// IDで取引を取得できること
    func test_getTransaction_正常系_ID指定() async throws {
        // Given
        let targetId = UUID()
        let transactions = [
            Transaction(id: targetId, amount: 1000, categoryName: "食費"),
            Transaction(amount: 2000, categoryName: "交通費")
        ]
        mockRepository.transactionsToReturn = transactions

        // When
        let result = try await sut.execute(id: targetId)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, targetId)
    }

    /// 存在しないIDの場合nilを返すこと
    func test_getTransaction_正常系_存在しないID() async throws {
        // Given
        mockRepository.transactionsToReturn = [
            Transaction(amount: 1000, categoryName: "食費")
        ]

        // When
        let result = try await sut.execute(id: UUID())

        // Then
        XCTAssertNil(result)
    }
}

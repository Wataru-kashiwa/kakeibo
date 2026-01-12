import XCTest
@testable import BudgetApp

/// DeleteTransactionUseCaseの単体テスト
final class DeleteTransactionUseCaseTests: XCTestCase {
    var sut: DeleteTransactionUseCase!
    var mockRepository: MockTransactionRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockTransactionRepository()
        sut = DeleteTransactionUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    /// 正常に取引が削除されること
    func test_deleteTransaction_正常系() async throws {
        // Given
        let transactionId = UUID()

        // When
        try await sut.execute(id: transactionId)

        // Then
        XCTAssertEqual(mockRepository.deletedIds.count, 1)
        XCTAssertEqual(mockRepository.deletedIds.first, transactionId)
    }

    /// リポジトリがエラーを返す場合、エラーがスローされること
    func test_deleteTransaction_異常系_削除失敗() async {
        // Given
        mockRepository.errorToThrow = RepositoryError.deleteFailed(
            underlying: NSError(domain: "test", code: 1)
        )

        // When & Then
        do {
            try await sut.execute(id: UUID())
            XCTFail("エラーがスローされるべき")
        } catch {
            XCTAssertTrue(error is RepositoryError)
        }
    }
}

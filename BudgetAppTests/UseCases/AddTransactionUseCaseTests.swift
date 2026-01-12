import XCTest
@testable import BudgetApp

/// AddTransactionUseCaseの単体テスト
final class AddTransactionUseCaseTests: XCTestCase {
    var sut: AddTransactionUseCase!
    var mockRepository: MockTransactionRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockTransactionRepository()
        sut = AddTransactionUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    /// 正常に取引が追加されること
    func test_addTransaction_正常系() async throws {
        // Given
        let amount: Decimal = 1500
        let date = Date()
        let categoryName = "食費"
        let memo = "ランチ"

        // When
        let result = try await sut.execute(
            amount: amount,
            date: date,
            categoryName: categoryName,
            memo: memo,
            sourceText: nil,
            source: .app
        )

        // Then
        XCTAssertEqual(result.amount, amount)
        XCTAssertEqual(result.categoryName, categoryName)
        XCTAssertEqual(result.memo, memo)
        XCTAssertEqual(result.source, .app)
        XCTAssertEqual(mockRepository.savedTransactions.count, 1)
    }

    /// Share Extensionからの追加が正常に動作すること
    func test_addTransaction_正常系_ShareExtension() async throws {
        // Given
        let sourceText = "楽天カード ¥3,000"

        // When
        let result = try await sut.execute(
            amount: 3000,
            date: Date(),
            categoryName: nil,
            memo: sourceText,
            sourceText: sourceText,
            source: .shareExtension
        )

        // Then
        XCTAssertEqual(result.source, .shareExtension)
        XCTAssertEqual(result.sourceText, sourceText)
    }

    /// すべての項目がnilでも保存できること
    func test_addTransaction_正常系_最小限の入力() async throws {
        // Given & When
        let result = try await sut.execute(
            amount: nil,
            date: Date(),
            categoryName: nil,
            memo: nil,
            sourceText: nil,
            source: .app
        )

        // Then
        XCTAssertNil(result.amount)
        XCTAssertNil(result.categoryName)
        XCTAssertNil(result.memo)
        XCTAssertEqual(mockRepository.savedTransactions.count, 1)
    }

    /// リポジトリがエラーを返す場合、エラーがスローされること
    func test_addTransaction_異常系_保存失敗() async {
        // Given
        mockRepository.errorToThrow = RepositoryError.saveFailed(
            underlying: NSError(domain: "test", code: 1)
        )

        // When & Then
        do {
            _ = try await sut.execute(
                amount: 1000,
                date: Date(),
                categoryName: nil,
                memo: nil,
                sourceText: nil,
                source: .app
            )
            XCTFail("エラーがスローされるべき")
        } catch {
            XCTAssertTrue(error is RepositoryError)
        }
    }
}

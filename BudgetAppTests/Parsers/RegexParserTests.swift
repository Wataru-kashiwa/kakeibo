import XCTest
@testable import BudgetApp

/// RegexParserの単体テスト
final class RegexParserTests: XCTestCase {
    var sut: RegexParser!

    override func setUp() {
        super.setUp()
        sut = RegexParser()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - extractAmount Tests

    /// 円記号ありの金額を正しく抽出できること
    func test_extractAmount_正常系_円記号あり() {
        // Given
        let text = "商品代金 ¥1,234"

        // When
        let result = sut.extractAmount(from: text)

        // Then
        XCTAssertEqual(result, Decimal(1234))
    }

    /// 全角円記号ありの金額を正しく抽出できること
    func test_extractAmount_正常系_全角円記号あり() {
        // Given
        let text = "商品代金 ￥5,678"

        // When
        let result = sut.extractAmount(from: text)

        // Then
        XCTAssertEqual(result, Decimal(5678))
    }

    /// カンマ区切りの金額を正しく抽出できること
    func test_extractAmount_正常系_カンマ区切り() {
        // Given
        let text = "合計金額：12,345円"

        // When
        let result = sut.extractAmount(from: text)

        // Then
        XCTAssertEqual(result, Decimal(12345))
    }

    /// 円で終わる金額を正しく抽出できること
    func test_extractAmount_正常系_円で終わる() {
        // Given
        let text = "980円のお支払い"

        // When
        let result = sut.extractAmount(from: text)

        // Then
        XCTAssertEqual(result, Decimal(980))
    }

    /// 数字がない場合はnilを返すこと
    func test_extractAmount_異常系_数字なし() {
        // Given
        let text = "テキストのみ"

        // When
        let result = sut.extractAmount(from: text)

        // Then
        XCTAssertNil(result)
    }

    /// 空文字の場合はnilを返すこと
    func test_extractAmount_異常系_空文字() {
        // Given
        let text = ""

        // When
        let result = sut.extractAmount(from: text)

        // Then
        XCTAssertNil(result)
    }

    // MARK: - parse Tests

    /// テキストを解析して金額が抽出されること
    func test_parse_正常系_金額抽出() async {
        // Given
        let text = "楽天カード ¥3,000 2024/01/15"

        // When
        let result = await sut.parse(text)

        // Then
        XCTAssertEqual(result.amount, Decimal(3000))
        XCTAssertEqual(result.memo, text)
        XCTAssertEqual(result.parserUsed, "regex_parser")
        XCTAssertGreaterThan(result.confidence, 0)
    }

    /// 金額がない場合でもメモが設定されること
    func test_parse_正常系_金額なし() async {
        // Given
        let text = "メモのみのテキスト"

        // When
        let result = await sut.parse(text)

        // Then
        XCTAssertNil(result.amount)
        XCTAssertEqual(result.memo, text)
    }

    // MARK: - canHandle Tests

    /// 金額パターンがある場合は高い信頼度を返すこと
    func test_canHandle_正常系_金額パターンあり() {
        // Given
        let text = "支払い ¥1,000"

        // When
        let result = sut.canHandle(text)

        // Then
        XCTAssertGreaterThanOrEqual(result, 0.6)
    }

    /// 金額パターンがない場合は低い信頼度を返すこと
    func test_canHandle_正常系_金額パターンなし() {
        // Given
        let text = "テキストのみ"

        // When
        let result = sut.canHandle(text)

        // Then
        XCTAssertLessThan(result, 0.6)
        XCTAssertGreaterThan(result, 0)
    }

    /// 空文字の場合は0を返すこと
    func test_canHandle_異常系_空文字() {
        // Given
        let text = ""

        // When
        let result = sut.canHandle(text)

        // Then
        XCTAssertEqual(result, 0)
    }
}

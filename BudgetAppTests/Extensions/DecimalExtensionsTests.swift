import XCTest
@testable import BudgetApp

/// Decimal拡張の単体テスト
final class DecimalExtensionsTests: XCTestCase {

    /// 日本円フォーマットが正しく動作すること
    func test_toJPYString_正常系() {
        // Given
        let decimal: Decimal = 1234

        // When
        let result = decimal.toJPYString()

        // Then
        XCTAssertTrue(result.contains("1,234") || result.contains("1234"))
        XCTAssertTrue(result.contains("¥") || result.contains("￥"))
    }

    /// カンマ区切りフォーマットが正しく動作すること
    func test_toFormattedString_正常系() {
        // Given
        let decimal: Decimal = 1234567

        // When
        let result = decimal.toFormattedString()

        // Then
        XCTAssertTrue(result.contains(","))
    }

    /// Optional<Decimal>のnilの場合プレースホルダーが返されること
    func test_optionalToJPYString_nil() {
        // Given
        let decimal: Decimal? = nil

        // When
        let result = decimal.toJPYString()

        // Then
        XCTAssertEqual(result, "-")
    }

    /// Optional<Decimal>のnilの場合カスタムプレースホルダーが返されること
    func test_optionalToJPYString_nilWithCustomPlaceholder() {
        // Given
        let decimal: Decimal? = nil

        // When
        let result = decimal.toJPYString(placeholder: "未入力")

        // Then
        XCTAssertEqual(result, "未入力")
    }

    /// Optional<Decimal>に値がある場合フォーマットされること
    func test_optionalToJPYString_hasValue() {
        // Given
        let decimal: Decimal? = 5000

        // When
        let result = decimal.toJPYString()

        // Then
        XCTAssertTrue(result.contains("5,000") || result.contains("5000"))
    }
}

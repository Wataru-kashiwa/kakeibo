import XCTest
@testable import BudgetApp

/// Date拡張の単体テスト
final class DateExtensionsTests: XCTestCase {

    /// 月の開始日が正しく取得できること
    func test_startOfMonth_正常系() {
        // Given
        let calendar = Calendar.current
        let components = DateComponents(year: 2024, month: 3, day: 15)
        let date = calendar.date(from: components)!

        // When
        let result = date.startOfMonth

        // Then
        let resultComponents = calendar.dateComponents([.year, .month, .day], from: result)
        XCTAssertEqual(resultComponents.year, 2024)
        XCTAssertEqual(resultComponents.month, 3)
        XCTAssertEqual(resultComponents.day, 1)
    }

    /// 月の終了日が正しく取得できること
    func test_endOfMonth_正常系() {
        // Given
        let calendar = Calendar.current
        let components = DateComponents(year: 2024, month: 3, day: 15)
        let date = calendar.date(from: components)!

        // When
        let result = date.endOfMonth

        // Then
        let resultComponents = calendar.dateComponents([.year, .month, .day], from: result)
        XCTAssertEqual(resultComponents.year, 2024)
        XCTAssertEqual(resultComponents.month, 3)
        XCTAssertEqual(resultComponents.day, 31)
    }

    /// 同じ日付の判定が正しく動作すること
    func test_isSameDay_正常系_同じ日() {
        // Given
        let calendar = Calendar.current
        var components1 = DateComponents(year: 2024, month: 3, day: 15, hour: 10)
        var components2 = DateComponents(year: 2024, month: 3, day: 15, hour: 20)
        let date1 = calendar.date(from: components1)!
        let date2 = calendar.date(from: components2)!

        // When
        let result = date1.isSameDay(as: date2)

        // Then
        XCTAssertTrue(result)
    }

    /// 異なる日付の判定が正しく動作すること
    func test_isSameDay_正常系_異なる日() {
        // Given
        let calendar = Calendar.current
        let components1 = DateComponents(year: 2024, month: 3, day: 15)
        let components2 = DateComponents(year: 2024, month: 3, day: 16)
        let date1 = calendar.date(from: components1)!
        let date2 = calendar.date(from: components2)!

        // When
        let result = date1.isSameDay(as: date2)

        // Then
        XCTAssertFalse(result)
    }

    /// 日数加算が正しく動作すること
    func test_addingDays_正常系() {
        // Given
        let calendar = Calendar.current
        let components = DateComponents(year: 2024, month: 3, day: 15)
        let date = calendar.date(from: components)!

        // When
        let result = date.addingDays(5)

        // Then
        let resultComponents = calendar.dateComponents([.day], from: result)
        XCTAssertEqual(resultComponents.day, 20)
    }

    /// 月数加算が正しく動作すること
    func test_addingMonths_正常系() {
        // Given
        let calendar = Calendar.current
        let components = DateComponents(year: 2024, month: 3, day: 15)
        let date = calendar.date(from: components)!

        // When
        let result = date.addingMonths(2)

        // Then
        let resultComponents = calendar.dateComponents([.month], from: result)
        XCTAssertEqual(resultComponents.month, 5)
    }
}

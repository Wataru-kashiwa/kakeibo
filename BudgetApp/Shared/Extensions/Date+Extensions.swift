import Foundation

/// Date型の拡張
extension Date {
    /// 月の開始日を取得する
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    /// 月の終了日を取得する
    var endOfMonth: Date {
        let calendar = Calendar.current
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth),
              let endOfMonth = calendar.date(byAdding: .day, value: -1, to: nextMonth) else {
            return self
        }
        // 23:59:59に設定
        return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endOfMonth) ?? endOfMonth
    }

    /// 日本語の日付フォーマットで文字列に変換する
    /// - Parameter style: DateFormatter.Style
    /// - Returns: フォーマットされた日付文字列
    func toJapaneseString(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// 日付のみを比較する（時刻を無視）
    /// - Parameter other: 比較対象の日付
    /// - Returns: 同じ日付かどうか
    func isSameDay(as other: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: other)
    }

    /// 指定日数を加算した日付を返す
    /// - Parameter days: 加算する日数
    /// - Returns: 加算後の日付
    func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// 指定月数を加算した日付を返す
    /// - Parameter months: 加算する月数
    /// - Returns: 加算後の日付
    func addingMonths(_ months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
}

import Foundation

/// Decimal型の拡張
extension Decimal {
    /// 日本円フォーマットで文字列に変換する
    /// - Returns: フォーマットされた金額文字列（例：¥1,234）
    func toJPYString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "JPY"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self as NSDecimalNumber) ?? "¥0"
    }

    /// カンマ区切りの数字文字列に変換する
    /// - Returns: フォーマットされた文字列（例：1,234）
    func toFormattedString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self as NSDecimalNumber) ?? "0"
    }
}

/// Optional<Decimal>の拡張
extension Optional where Wrapped == Decimal {
    /// 日本円フォーマットで文字列に変換する
    /// - Parameter placeholder: nilの場合の代替文字列
    /// - Returns: フォーマットされた金額文字列
    func toJPYString(placeholder: String = "-") -> String {
        guard let value = self else {
            return placeholder
        }
        return value.toJPYString()
    }
}

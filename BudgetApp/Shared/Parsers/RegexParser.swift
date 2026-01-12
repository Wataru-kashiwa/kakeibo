import Foundation

/// 正規表現を使用して取引情報を抽出するパーサー
final class RegexParser: TransactionParser {
    let identifier = "regex_parser"

    /// テキストを解析して取引情報を抽出する
    /// - Parameter text: 解析対象のテキスト
    /// - Returns: 解析結果
    func parse(_ text: String) async -> ParseResult {
        var result = ParseResult.empty(parserUsed: identifier)

        // 金額の抽出
        if let amount = extractAmount(from: text) {
            result.amount = amount
            result.confidence += 0.5
        }

        // 日付の抽出（Phase 3で拡張予定）
        // result.date = extractDate(from: text)

        // メモとしてテキスト全体を設定
        result.memo = text.trimmingCharacters(in: .whitespacesAndNewlines)

        return result
    }

    /// このパーサーがテキストを処理できるかの信頼度を返す
    /// - Parameter text: 判定対象のテキスト
    /// - Returns: 信頼度スコア
    func canHandle(_ text: String) -> Double {
        // 金額パターンが含まれていれば処理可能
        if extractAmount(from: text) != nil {
            return 0.6
        }
        // テキストがあれば最低限処理可能
        return text.isEmpty ? 0.0 : 0.3
    }

    /// テキストから金額を抽出する
    /// - Parameter text: 解析対象のテキスト
    /// - Returns: 抽出された金額（Decimal）
    func extractAmount(from text: String) -> Decimal? {
        // 金額パターンの正規表現
        // 対応形式: ¥1,234 / 1,234円 / 1234円 / ￥1234 / 1,234.56円
        let patterns = [
            #"[¥￥]\s*([0-9,]+(?:\.[0-9]+)?)"#,        // ¥1,234 or ￥1234
            #"([0-9,]+(?:\.[0-9]+)?)\s*円"#,          // 1,234円
            #"金額[：:]\s*([0-9,]+(?:\.[0-9]+)?)"#,   // 金額：1,234
            #"([0-9]{1,3}(?:,[0-9]{3})+)(?![0-9])"#   // カンマ区切りの数字
        ]

        for pattern in patterns {
            if let amount = extractFirstMatch(pattern: pattern, from: text) {
                return amount
            }
        }

        return nil
    }

    /// 正規表現パターンにマッチする最初の金額を抽出する
    /// - Parameters:
    ///   - pattern: 正規表現パターン
    ///   - text: 解析対象のテキスト
    /// - Returns: 抽出された金額
    private func extractFirstMatch(pattern: String, from text: String) -> Decimal? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }

        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range),
              match.numberOfRanges > 1,
              let matchRange = Range(match.range(at: 1), in: text) else {
            return nil
        }

        let matchedString = String(text[matchRange])
        // カンマを除去して数値に変換
        let cleanedString = matchedString.replacingOccurrences(of: ",", with: "")
        return Decimal(string: cleanedString)
    }
}

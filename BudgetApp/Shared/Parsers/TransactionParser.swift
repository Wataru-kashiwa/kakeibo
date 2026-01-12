import Foundation

/// 取引情報を解析するパーサーのプロトコル
/// 各金融サービスごとに異なる実装を提供可能
protocol TransactionParser {
    /// パーサーの識別子
    var identifier: String { get }

    /// テキストを解析して取引情報を抽出する
    /// - Parameter text: 解析対象のテキスト
    /// - Returns: 解析結果
    func parse(_ text: String) async -> ParseResult

    /// このパーサーがテキストを処理できるかの信頼度を返す
    /// - Parameter text: 判定対象のテキスト
    /// - Returns: 信頼度スコア（0.0〜1.0）
    func canHandle(_ text: String) -> Double
}

/// パーサーの解析結果
struct ParseResult: Equatable {
    /// 抽出された金額
    var amount: Decimal?
    /// 抽出された日付
    var date: Date?
    /// 抽出されたメモ
    var memo: String?
    /// 推定されたカテゴリ
    var category: String?
    /// 解析の信頼度（0.0〜1.0）
    var confidence: Double
    /// 使用したパーサーの識別子
    var parserUsed: String

    /// 空の結果を生成する
    static func empty(parserUsed: String) -> ParseResult {
        ParseResult(
            amount: nil,
            date: nil,
            memo: nil,
            category: nil,
            confidence: 0.0,
            parserUsed: parserUsed
        )
    }
}

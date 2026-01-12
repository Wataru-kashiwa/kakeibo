import Foundation
import Combine

/// 取引一覧画面のViewModel
@MainActor
final class TransactionListViewModel: ObservableObject {
    // MARK: - Published Properties

    /// 取引一覧
    @Published private(set) var transactions: [Transaction] = []
    /// ローディング状態
    @Published private(set) var isLoading: Bool = false
    /// エラーメッセージ
    @Published var errorMessage: String?
    /// 新規追加シート表示フラグ
    @Published var showingAddSheet: Bool = false
    /// 編集対象の取引
    @Published var editingTransaction: Transaction?

    // MARK: - Properties

    private let getTransactionsUseCase: GetTransactionsUseCase
    private let deleteTransactionUseCase: DeleteTransactionUseCase

    // MARK: - Computed Properties

    /// 日付でグループ化された取引
    var groupedTransactions: [(date: Date, transactions: [Transaction])] {
        let grouped = Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
        return grouped
            .sorted { $0.key > $1.key }
            .map { (date: $0.key, transactions: $0.value) }
    }

    /// 今月の支出合計
    var currentMonthTotal: Decimal {
        let now = Date()
        let startOfMonth = now.startOfMonth
        let endOfMonth = now.endOfMonth

        return transactions
            .filter { $0.date >= startOfMonth && $0.date <= endOfMonth }
            .compactMap { $0.amount }
            .reduce(0, +)
    }

    // MARK: - Initialization

    /// 初期化
    /// - Parameters:
    ///   - getTransactionsUseCase: 取引取得ユースケース
    ///   - deleteTransactionUseCase: 取引削除ユースケース
    init(
        getTransactionsUseCase: GetTransactionsUseCase,
        deleteTransactionUseCase: DeleteTransactionUseCase
    ) {
        self.getTransactionsUseCase = getTransactionsUseCase
        self.deleteTransactionUseCase = deleteTransactionUseCase
    }

    // MARK: - Methods

    /// 取引一覧を読み込む
    func loadTransactions() async {
        isLoading = true
        errorMessage = nil

        do {
            transactions = try await getTransactionsUseCase.execute()
        } catch {
            errorMessage = "取引の読み込みに失敗しました: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// 取引を削除する
    /// - Parameter transaction: 削除する取引
    func deleteTransaction(_ transaction: Transaction) async {
        do {
            try await deleteTransactionUseCase.execute(id: transaction.id)
            // ローカルの配列からも削除
            transactions.removeAll { $0.id == transaction.id }
        } catch {
            errorMessage = "削除に失敗しました: \(error.localizedDescription)"
        }
    }

    /// 複数の取引を削除する
    /// - Parameter offsets: 削除するインデックス
    func deleteTransactions(at offsets: IndexSet, in dateTransactions: [Transaction]) async {
        for offset in offsets {
            let transaction = dateTransactions[offset]
            await deleteTransaction(transaction)
        }
    }
}

import Foundation

/// DIコンテナ
/// アプリ全体で使用する依存関係を管理する
/// 注: 本番ではFactoryライブラリを使用することを推奨
final class AppContainer {
    /// シングルトンインスタンス
    static let shared = AppContainer()

    /// 取引リポジトリ
    lazy var transactionRepository: TransactionRepositoryProtocol = {
        LocalTransactionRepository()
    }()

    /// 取引追加ユースケース
    lazy var addTransactionUseCase: AddTransactionUseCase = {
        AddTransactionUseCase(repository: transactionRepository)
    }()

    /// 取引取得ユースケース
    lazy var getTransactionsUseCase: GetTransactionsUseCase = {
        GetTransactionsUseCase(repository: transactionRepository)
    }()

    /// 取引更新ユースケース
    lazy var updateTransactionUseCase: UpdateTransactionUseCase = {
        UpdateTransactionUseCase(repository: transactionRepository)
    }()

    /// 取引削除ユースケース
    lazy var deleteTransactionUseCase: DeleteTransactionUseCase = {
        DeleteTransactionUseCase(repository: transactionRepository)
    }()

    /// 予算計算ユースケース
    lazy var calculateBudgetUseCase: CalculateBudgetUseCase = {
        CalculateBudgetUseCase(repository: transactionRepository)
    }()

    private init() {}
}

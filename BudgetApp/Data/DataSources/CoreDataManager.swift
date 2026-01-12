import CoreData
import Foundation

/// Core Dataの永続化コンテナを管理するクラス
/// App GroupsによりメインアプリとShare Extension間でデータを共有する
final class CoreDataManager {
    /// シングルトンインスタンス
    static let shared = CoreDataManager()

    /// App Groupの識別子
    /// 実際のプロジェクトでは適切なApp Group IDに変更すること
    private static let appGroupIdentifier = "group.com.budgetapp.shared"

    /// Core Dataモデル名
    private static let modelName = "BudgetApp"

    /// 永続化コンテナ
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Self.modelName)

        // App Groupsの共有ディレクトリにストアを配置
        if let storeURL = containerURL {
            let storeDescription = NSPersistentStoreDescription(url: storeURL)
            // データ保護レベルの設定（暗号化）
            storeDescription.setOption(
                FileProtectionType.complete as NSObject,
                forKey: NSPersistentStoreFileProtectionKey
            )
            // Persistent History Trackingの有効化（Share Extension連携用）
            storeDescription.setOption(
                true as NSNumber,
                forKey: NSPersistentHistoryTrackingKey
            )
            storeDescription.setOption(
                true as NSNumber,
                forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
            )
            container.persistentStoreDescriptions = [storeDescription]
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // 本番環境では適切なエラーハンドリングを行う
                fatalError("Core Data store failed to load: \(error), \(error.userInfo)")
            }
        }

        // マージポリシーの設定
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    /// App Groupsの共有ディレクトリURL
    private var containerURL: URL? {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Self.appGroupIdentifier
        )?.appendingPathComponent("\(Self.modelName).sqlite")
    }

    /// メインスレッド用のコンテキスト
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    /// プライベート初期化
    private init() {}

    /// バックグラウンドコンテキストを生成する
    /// - Returns: 新しいバックグラウンドコンテキスト
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        // メモリ節約のためUndoManagerを無効化
        context.undoManager = nil
        return context
    }

    /// 変更を保存する
    /// - Parameter context: 保存するコンテキスト
    /// - Throws: 保存に失敗した場合のエラー
    func save(context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        try context.save()
    }

    /// バックグラウンドで処理を実行し保存する
    /// - Parameter block: 実行する処理
    /// - Throws: 処理または保存に失敗した場合のエラー
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        let context = newBackgroundContext()
        return try await context.perform {
            let result = try block(context)
            try self.save(context: context)
            return result
        }
    }
}

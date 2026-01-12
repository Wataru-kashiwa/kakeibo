import SwiftUI

/// アプリケーションのエントリーポイント
@main
struct BudgetAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// メインコンテンツビュー
struct ContentView: View {
    var body: some View {
        TabView {
            TransactionListView(
                viewModel: TransactionListViewModel(
                    getTransactionsUseCase: AppContainer.shared.getTransactionsUseCase,
                    deleteTransactionUseCase: AppContainer.shared.deleteTransactionUseCase
                )
            )
            .tabItem {
                Label("取引", systemImage: "list.bullet")
            }

            // Phase 2: 予算管理
            PlaceholderView(title: "予算", icon: "chart.pie")
                .tabItem {
                    Label("予算", systemImage: "chart.pie")
                }

            // Phase 2: レポート
            PlaceholderView(title: "レポート", icon: "chart.bar")
                .tabItem {
                    Label("レポート", systemImage: "chart.bar")
                }

            // 設定
            PlaceholderView(title: "設定", icon: "gearshape")
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
        }
    }
}

/// プレースホルダービュー（Phase 2以降で実装）
struct PlaceholderView: View {
    let title: String
    let icon: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                Text("Coming Soon")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle(title)
        }
    }
}

#Preview {
    ContentView()
}

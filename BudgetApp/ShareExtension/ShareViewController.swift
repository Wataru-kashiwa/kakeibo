import UIKit
import SwiftUI
import UniformTypeIdentifiers

/// Share Extensionのメインビューコントローラー
/// UIKitベースでSwiftUIビューをホストする
class ShareViewController: UIViewController {
    /// 共有されたテキスト
    private var sharedText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        extractSharedContent()
    }

    /// 共有コンテンツからテキストを抽出する
    private func extractSharedContent() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProviders = extensionItem.attachments else {
            presentShareView(with: "")
            return
        }

        // テキストを抽出
        let textType = UTType.plainText.identifier
        for provider in itemProviders {
            if provider.hasItemConformingToTypeIdentifier(textType) {
                provider.loadItem(forTypeIdentifier: textType, options: nil) { [weak self] item, error in
                    DispatchQueue.main.async {
                        if let text = item as? String {
                            self?.presentShareView(with: text)
                        } else {
                            self?.presentShareView(with: "")
                        }
                    }
                }
                return
            }
        }

        // URLの場合
        let urlType = UTType.url.identifier
        for provider in itemProviders {
            if provider.hasItemConformingToTypeIdentifier(urlType) {
                provider.loadItem(forTypeIdentifier: urlType, options: nil) { [weak self] item, error in
                    DispatchQueue.main.async {
                        if let url = item as? URL {
                            self?.presentShareView(with: url.absoluteString)
                        } else {
                            self?.presentShareView(with: "")
                        }
                    }
                }
                return
            }
        }

        presentShareView(with: "")
    }

    /// SwiftUIビューを表示する
    /// - Parameter text: 共有されたテキスト
    private func presentShareView(with text: String) {
        let viewModel = ExpenseShareViewModel(
            sharedText: text,
            onSave: { [weak self] in
                self?.completeRequest()
            },
            onCancel: { [weak self] in
                self?.cancelRequest()
            }
        )

        let shareView = ExpenseShareView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: shareView)

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)
    }

    /// 保存完了後にExtensionを閉じる
    private func completeRequest() {
        extensionContext?.completeRequest(returningItems: nil) { _ in
            // ハプティックフィードバック
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    /// キャンセル時にExtensionを閉じる
    private func cancelRequest() {
        extensionContext?.cancelRequest(withError: NSError(
            domain: "com.budgetapp.share",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "ユーザーによりキャンセルされました"]
        ))
    }
}

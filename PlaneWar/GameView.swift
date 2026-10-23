import SwiftUI
import WebKit

struct GameView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let cfg = WKWebViewConfiguration()
        // 自定义 scheme 加载包内游戏文件，localStorage（最高分）据此持久化
        cfg.setURLSchemeHandler(ThunderSchemeHandler(), forURLScheme: ThunderSchemeHandler.scheme)
        cfg.websiteDataStore = .default()
        cfg.allowsInlineMediaPlayback = true

        let wv = WKWebView(frame: .zero, configuration: cfg)
        wv.isOpaque = false
        wv.backgroundColor = .black
        wv.scrollView.isScrollEnabled = false
        wv.scrollView.bounces = false
        wv.scrollView.contentInsetAdjustmentBehavior = .never

        let url = URL(string: "\(ThunderSchemeHandler.scheme)://bundle/index.html")!
        wv.load(URLRequest(url: url))

        UIApplication.shared.isIdleTimerDisabled = true   // 游戏中不息屏
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    static func dismantleUIView(_ uiView: WKWebView, coordinator: ()) {
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

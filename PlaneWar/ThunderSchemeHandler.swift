import WebKit

/// 把打包进 app 的 game.html 以 thunder://bundle/index.html 的形式提供给 WKWebView。
/// 用 http(s)/file 直载会让 localStorage 不可靠，自定义 scheme 的 origin 是稳定的。
final class ThunderSchemeHandler: NSObject, WKURLSchemeHandler {
    static let scheme = "thunder"

    func webView(_ webView: WKWebView, start task: WKURLSchemeTask) {
        guard let url = task.request.url,
              url.host?.lowercased() == "bundle",
              let file = Bundle.main.url(forResource: "game", withExtension: "html")
        else {
            task.didFailWithError(URLError(.fileDoesNotExist))
            return
        }
        do {
            let data = try Data(contentsOf: file)
            let rsp = URLResponse(url: url, mimeType: "text/html",
                                  expectedContentLength: data.count, textEncodingName: "utf-8")
            task.didReceive(rsp)
            task.didReceive(data)
            task.didFinish()
        } catch {
            task.didFailWithError(error)
        }
    }

    func webView(_ webView: WKWebView, stop task: WKURLSchemeTask) {}
}

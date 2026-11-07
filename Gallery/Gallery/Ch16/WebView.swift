import SwiftUI
import WebKit

// <webview>
/// Exercise 16.4: WKWebView wrapped for SwiftUI, reporting the page title.
struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var title: String

    func makeCoordinator() -> Coordinator { Coordinator(title: $title) }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        return view
    }

    func updateUIView(_ view: WKWebView, context: Context) {
        context.coordinator.title = $title
        if view.url != url { view.load(URLRequest(url: url)) }  // reload only on change
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var title: Binding<String>
        init(title: Binding<String>) { self.title = title }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            title.wrappedValue = webView.title ?? ""
        }
    }
}
// </webview>

struct WebViewExample: View {
    @State private var title = ""
    // A local page, so the example works offline.
    let url = URL(string: "data:text/html,<title>Hello%20WebKit</title><h1>Hello</h1>")!

    var body: some View {
        VStack {
            Text("Title: \(title)").font(.headline)
            WebView(url: url, title: $title)
        }
    }
}

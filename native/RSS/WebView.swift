//
//  WebView.swift
//  RSS
//
//  Created by Omar Estrella on 8/30/22.
//

import Combine
import SwiftUI
import WebKit

struct WebView {
  @EnvironmentObject var shortcutManager: ShortcutManager

  var url: String
  private let webView = WKWebView()

  init(url: String) {
    self.url = url
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(webView)
  }

  class Coordinator: NSObject, WKNavigationDelegate {
    private var webView: WKWebView

    var shortcutManager: ShortcutManager? {
      didSet {
        shortcutManager?.addShortcut(
          .init(type: .native,
                placement: .file,
                label: "Reload",
                key: "R",
                modifiers: [.command],
                handler: reload))
      }
    }

    init(_ webView: WKWebView) {
      self.webView = webView

      JavaScriptBridge.instance.initialize(webView)
    }

    // MARK: Internal API

    func reload() {
      webView.reload()
    }

    // MARK: WKNaviagationDelete

    public func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {}

    public func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError error: Error) {
      print("ERROR!", error)
    }

    public func webView(_: WKWebView, didFinish _: WKNavigation!) {}

    public func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
      shortcutManager?.clearClientShortcuts()
    }

    public func webView(_: WKWebView, decidePolicyFor _: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
      decisionHandler(.allow)
    }
  }
}

#if os(macOS)
extension WebView: NSViewRepresentable {
  typealias NSViewType = WKWebView

  func updateNSView(_: WKWebView, context _: NSViewRepresentableContext<WebView>) {}

  func makeNSView(context: NSViewRepresentableContext<WebView>) -> WKWebView {
    context.coordinator.shortcutManager = shortcutManager

    webView.navigationDelegate = context.coordinator
    webView.uiDelegate = context.coordinator as? WKUIDelegate
    if let url = URL(string: url) {
      webView.load(URLRequest(url: url))
    }
    return webView
  }
}
#else
import UIKit

extension WebView: UIViewRepresentable {
  func makeUIView(context _: Context) -> WKWebView {
    webView.navigationDelegate = context.coordinator
    webView.uiDelegate = context.coordinator as? WKUIDelegate
    webView.load(URLRequest(url: viewModel.url))
    return webView
  }

  func updateUIView(_: WKWebView, context _: Context) {}
}
#endif

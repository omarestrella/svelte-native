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
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.openURL) var openURL

  var url: URL

  private let webView = WKWebView()

  init(url: URL) {
    self.url = url
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(webView, self)
  }

  class Coordinator: NSObject, WKNavigationDelegate {
    private var webView: WKWebView
    private var hostView: WebView

    init(_ webView: WKWebView, _ hostView: WebView) {
      self.webView = webView
      self.hostView = hostView

      JavaScriptBridge.default.initialize(webView, hostView.colorScheme)
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

    public func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {}

    public func webView(_: WKWebView, decidePolicyFor navigation: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
      switch navigation.navigationType {
      case .linkActivated:
        decisionHandler(.cancel)
        if let url = navigation.request.url {
          hostView.openURL(url)
        }
      default:
        decisionHandler(.allow)
      }
    }
  }
}

#if os(macOS)
extension WebView: NSViewRepresentable {
  typealias NSViewType = WKWebView

  func updateNSView(_: WKWebView, context _: NSViewRepresentableContext<WebView>) {
    let scheme = colorScheme == .light ? "light" : "dark"
    JavaScriptBridge.default.send(.colorSchemeChanged(scheme))
  }

  func makeNSView(context: NSViewRepresentableContext<WebView>) -> WKWebView {
    webView.navigationDelegate = context.coordinator
    webView.uiDelegate = context.coordinator as? WKUIDelegate

    if url.isFileURL {
      print(url.deletingLastPathComponent())
      webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    } else {
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
    if url.isFileURL {
      webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    } else {
      webView.load(URLRequest(url: url))
    }

    return webView
  }

  func updateUIView(_: WKWebView, context _: Context) {}
}
#endif

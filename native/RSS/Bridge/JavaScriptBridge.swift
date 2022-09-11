//
//  JavaScriptBridge.swift
//  RSS
//
//  Created by Omar Estrella on 8/31/22.
//

import Foundation
import WebKit
import Combine

// Client -> Native
enum ClientEvent: String {
  case updateApplicationState
  case fetchFeed
}

// Native -> Client
enum HostMessage: Encodable {
  case fetchedFeed(feed: ClientFeed)
  case addFeed
  
  var messageData: (String, Encodable) {
    switch self {
    case .fetchedFeed(let feed):
      return ("fetchedFeed", feed)
    case .addFeed:
      return ("addFeed", "")
    }
  }
}

typealias EventCallback<T> = (_ data: T) -> Void

class JavaScriptBridge: NSObject, WKScriptMessageHandler {
  static var instance = JavaScriptBridge()

  var webView: WKWebView?
  
  var handlers: [ClientEvent: [(Any) -> Void]] = [:]

  func initialize(_ webView: WKWebView) {
    self.webView = webView
    webView.configuration.userContentController.add(self, name: "mobile")
  }

  func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
    do {
      let json = try JSONSerialization.data(withJSONObject: message.body, options: [])
      let decoder = JSONDecoder()
      let clientMessage = try decoder.decode(ClientMessage.self, from: json)
      
      switch clientMessage {
      case .updateApplicationState(let update):
        self.handlers[.updateApplicationState]?.forEach { $0(update) }
      case .fetchFeed(let feedRequest):
        self.handlers[.fetchFeed]?.forEach { $0(feedRequest) }
      case .log(let log):
        print("[Client Log] -", log.name, "\n", log.message ?? "")
        break
      case .error(let error):
        print("Got an error while decoding client message", error)
        break
      }
    } catch {
      print("Error parsing message from client", error.localizedDescription)
    }
  }

  
  func on<T: ClientRequest>(_ event: ClientEvent, handler: @escaping EventCallback<T>) {
    let wrapper: (Any) -> Void = { data in
      if let data = data as? T {
        handler(data)
      }
    }
    if handlers[event] == nil {
      handlers[event] = []
    }
    handlers[event]?.append(wrapper)
  }
  
  func send(_ message: HostMessage) {
    let (messageName, data) = message.messageData
    guard let encodedData = try? JSONEncoder().encode(data) else {
      print("Could not encode data to send to client")
      return
    }
    guard let stringData = String(data: encodedData, encoding: .utf8) else {
      print("Could not convert data to string to send to client")
      return
    }
    webView?.evaluateJavaScript("""
      JavaScriptBridge.emit("\(messageName)", \(stringData))
    """)
  }
}

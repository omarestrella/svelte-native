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
enum JavaScriptBridgeEvent {
  case updateApplicationState
  case fetchFeed
}

// Native -> Client
enum JavaScriptBridgeMessage: Encodable {
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

class ClientEventHandlers {
  var feedRequestHandlers: [EventCallback<FeedRequest>] = []
  var applicationUpdateRequestHandlers: [EventCallback<ApplicationUpdateRequest>] = []
  
  func on(feedRequest handler: @escaping EventCallback<FeedRequest>) {
    feedRequestHandlers.append(handler)
  }
  
  func on(applicationUpdateRequest handler: @escaping EventCallback<ApplicationUpdateRequest>) {
    applicationUpdateRequestHandlers.append(handler)
  }
  
  func emit<T>(_ event: JavaScriptBridgeEvent, data: T) {
    switch event {
    case .fetchFeed:
      guard let data = data as? FeedRequest else { return }
      feedRequestHandlers.forEach { $0(data) }
      break
    case .updateApplicationState:
      guard let data = data as? ApplicationUpdateRequest else { return }
      applicationUpdateRequestHandlers.forEach { $0(data) }
      break
    }
  }
}


class JavaScriptBridge: NSObject, WKScriptMessageHandler {
  static var instance = JavaScriptBridge()

  var webView: WKWebView?
  
  private var eventHandlers = ClientEventHandlers()

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
        eventHandlers.emit(.updateApplicationState, data: update)
      case .fetchFeed(let feedRequest):
        eventHandlers.emit(.fetchFeed, data: feedRequest)
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

  func on(feedRequest handler: @escaping EventCallback<FeedRequest>) {
    eventHandlers.on(feedRequest: handler)
  }
  
  func on(applicationUpdateRequest handler: @escaping EventCallback<ApplicationUpdateRequest>) {
    eventHandlers.on(applicationUpdateRequest: handler)
  }
  
  func send(_ message: JavaScriptBridgeMessage) {
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

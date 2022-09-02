//
//  JavaScriptBridge.swift
//  RSS
//
//  Created by Omar Estrella on 8/31/22.
//

import Foundation
import WebKit

// Client -> Native
enum JavaScriptBridgeEvent {
  case registerShortcut
  case removeShortcut
  
  case updateApplicationState
}

// Native -> Client
enum JavaScriptBridgeMessage: Encodable {
  case callShortcut(id: String)
  
  var messageData: (String, Encodable) {
    switch self {
    case .callShortcut(let id):
      return ("callShortcut", ["id": id])
    }
  }
}

struct EventHandler: Identifiable, Equatable {
  var id = UUID()
  var handler: (_: ClientMessage) -> Void
  
  static func == (lhs: EventHandler, rhs: EventHandler) -> Bool {
    lhs.id == rhs.id
  }
}

class JavaScriptBridge: NSObject, WKScriptMessageHandler {
  static var instance = JavaScriptBridge()

  var webView: WKWebView?
  
  var callbacks: [JavaScriptBridgeEvent: [EventHandler]] = [
    .registerShortcut: [],
    .removeShortcut: [],
    .updateApplicationState: []
  ]

  func initialize(_ webView: WKWebView) {
    self.webView = webView
    webView.configuration.userContentController.add(self, name: "mobile")
  }

  func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
    do {
      let json = try JSONSerialization.data(withJSONObject: message.body, options: [])
      let decoder = JSONDecoder()
      let message = try decoder.decode(ClientMessage.self, from: json)
      
      switch message {
      case .registerShortcut(_):
        emit(.registerShortcut, message: message)
        break
      case .removeShortcut(_):
        emit(.removeShortcut, message: message)
        break
      case .updateApplicationState(_):
        emit(.updateApplicationState, message: message)
      case .error(let error):
        print("Got an error while decoding client message", error)
        break
      }
    } catch {
      print("Error parsing message from client", error.localizedDescription)
    }
  }

  func on(_ event: JavaScriptBridgeEvent, _ handler: EventHandler) {
    callbacks[event]?.append(handler)
  }
  
  func off(_ event: JavaScriptBridgeEvent, _ handler: EventHandler) {
    let idx = callbacks[event]?.firstIndex(where: { $0 == handler })
    if let idx {
      callbacks[event]?.remove(at: idx)
    }
  }
  
  func emit(_ event: JavaScriptBridgeEvent, message: ClientMessage) {
    callbacks[event]?.forEach { handler in
      handler.handler(message)
    }
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

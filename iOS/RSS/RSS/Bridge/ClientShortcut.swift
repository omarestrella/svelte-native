//
//  ClientShortcut.swift
//  RSS
//
//  Created by Omar Estrella on 8/31/22.
//

import Foundation
import SwiftUI

struct ClientShortcut: Decodable {
  var id: String
  var label: String
  var placement: String
  var keyboardShortcut: ShortcutKeys
  
  func getPlacement() -> ShortcutPlacement {
    switch placement {
    case "file":
      return .file
    case "settings":
      return .settings
    default:
      return .file
    }
  }

  func toShortcut() -> Shortcut {
    let (key, modifiers) = keyboardShortcut.toKeyboardShortcut()
    return .init(id: UUID(uuidString: id)!,
                 type: .client,
                 placement: getPlacement(),
                 label: label,
                 key: key,
                 modifiers: modifiers,
                 handler: {
                   JavaScriptBridge.instance.send(.callShortcut(id: id))
                 })
  }
}

struct ShortcutKeys: Decodable {
  var key: String
  var modifiers: [String]

  func toKeyboardShortcut() -> (KeyEquivalent, [EventModifiers]) {
    (KeyEquivalent(Character(key)), getEventModifiers())
  }

  func getEventModifiers() -> [EventModifiers] {
    modifiers.compactMap { mod -> EventModifiers? in
      switch mod {
      case "command":
        return .command
      case "shift":
        return .shift
      case "ctrl":
        return .control
      case "option":
        return .option
      default:
        print("Could not parse modifier: \(mod)")
        return nil
      }
    }
  }
}

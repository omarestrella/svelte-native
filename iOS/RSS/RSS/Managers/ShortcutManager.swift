//
//  ShortcutManager.swift
//  RSS
//
//  Created by Omar Estrella on 8/30/22.
//

import Foundation
import Combine
import SwiftUI

enum ShortcutPlacement: Equatable {
  case file
  case settings
}

enum ShortcutType {
  case client
  case native
}

struct Shortcut: Identifiable {
  var id = UUID()
  var type: ShortcutType
  var placement: ShortcutPlacement
  var label: String
  var key: KeyEquivalent
  var modifiers: [EventModifiers]
  var handler: (() -> Void)
}

class ShortcutManager: ObservableObject {
  @Published var shortcuts: [Shortcut] = []
  
  init() {
    JavaScriptBridge.instance.on(.removeShortcut, .init(handler: { message in
      guard case .removeShortcut(let id) = message else {
        return
      }
      if let idx = self.shortcuts.firstIndex(where: { $0.id.uuidString == id.uppercased() }) {
        DispatchQueue.main.async {
          self.shortcuts.remove(at: idx)
        }
      }
    }))
  }
  
  func addShortcut(_ shortcut: Shortcut) {
    DispatchQueue.main.async {
      self.shortcuts.append(shortcut)
    }
  }
  
  func clearClientShortcuts() {
    self.shortcuts = self.shortcuts.filter { $0.type == .native }
  }
}

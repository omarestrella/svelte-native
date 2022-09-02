//
//  RSSApp.swift
//  RSS
//
//  Created by Omar Estrella on 8/30/22.
//

import SwiftUI

struct AppCommands: Commands {
  @ObservedObject var shortcutManager: ShortcutManager
  
  init(_ shortcutManager: ShortcutManager) {
    self.shortcutManager = shortcutManager
  }
  
  // [TODO]: maybe we can build the entire command group dynamically?
  @CommandsBuilder
  var body: some Commands {
    CommandGroup(after: .newItem, addition: {
      ForEach(shortcutManager.shortcuts) { shortcut in
        if shortcut.placement == .file {
          Button(shortcut.label) {
            shortcut.handler()
          }.keyboardShortcut(shortcut.key, modifiers: .init(shortcut.modifiers))
        }
      }
    })
    
    CommandGroup(after: .appSettings, addition: {
      ForEach(shortcutManager.shortcuts) { shortcut in
        if shortcut.placement == .settings {
          Button(shortcut.label) {
            shortcut.handler()
          }.keyboardShortcut(shortcut.key, modifiers: .init(shortcut.modifiers))
        }
      }
    })
  }
}

@main
struct RSSApp: App {
  var shortcutManager = ShortcutManager()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(shortcutManager)
    }
    .defaultSize(width: 1024, height: 1024)
    .commands {
      AppCommands(shortcutManager)
    }
  }
}

//
//  ContentView.swift
//  RSS
//
//  Created by Omar Estrella on 8/30/22.
//

import SwiftUI

struct ContentView: View {
  @EnvironmentObject var shortcutManager: ShortcutManager
  
  @ObservedObject var appModel = ApplicationModel()

  var body: some View {
    WebView(url: "http://127.0.0.1:5173")
      .navigationTitle(appModel.title)
      .navigationSubtitle(appModel.subtitle)
      .toolbar {
        ToolbarItem(placement: .navigation) {
          Button(action: {
            print("toolbar")
          }, label: {
            Label("toolbar", systemImage: "plus")
          })
        }
      }
      .onAppear {
        JavaScriptBridge.instance.on(.registerShortcut, .init(handler: { message in
          guard case let .registerShortcut(shortcut) = message else {
            return
          }
          shortcutManager.addShortcut(shortcut.toShortcut())
        }))
      }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

//
//  ContentView.swift
//  RSS
//
//  Created by Omar Estrella on 8/30/22.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject var appModel = ApplicationModel()
  
  var url: URL {
    #if DEBUG
    return URL(string: "http://127.0.0.1:5173")!
    #else
    return Bundle.main.url(forResource: "index", withExtension: "html")!
    #endif
  }

  var body: some View {
    WebView(url: url)
      .navigationTitle(appModel.title)
      .navigationSubtitle(appModel.subtitle)
      .toolbar {
        ToolbarItem(placement: .navigation) {
          Button(action: {
            JavaScriptBridge.default.send(.addFeed)
          }, label: {
            Label("add feed", systemImage: "plus")
          })
        }
      }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

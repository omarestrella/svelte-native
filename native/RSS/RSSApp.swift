//
//  RSSApp.swift
//  RSS
//
//  Created by Omar Estrella on 8/30/22.
//

import SwiftUI

@main
struct RSSApp: App {
  var feedManager = FeedManager()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(feedManager)
    }
    .defaultSize(width: 1024, height: 1024)
  }
}

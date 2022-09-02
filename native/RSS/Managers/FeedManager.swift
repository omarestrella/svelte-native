//
//  RSSManager.swift
//  RSS
//
//  Created by Omar Estrella on 9/1/22.
//

import Foundation
import FeedKit

struct ClientFeedItem: Encodable {
  var title: String
  var description: String

  static func from(item: RSSFeedItem) -> ClientFeedItem? {
    if let title = item.title, let description = item.description {
      return .init(title: title, description: description)
    }
    return nil
  }
}

struct ClientFeed: Encodable {
  var title: String
  var items: [ClientFeedItem]

  static func from(feed: RSSFeed) -> ClientFeed? {
    if let title = feed.title, let items = feed.items {
      return .init(title: title, items: items.compactMap { .from(item: $0) })
    }
    return nil
  }
}

class FeedManager: ObservableObject {
  init() {
    registerListeners()
  }
  
  func registerListeners() {
    JavaScriptBridge.instance.on(.fetchFeed, .init(handler: { message in
      guard case .fetchFeed(let url) = message else {
        return
      }
      
      guard let feedURL = URL(string: url) else {
        return
      }
      
      FeedParser(URL: feedURL).parseAsync(result: { (result) in
        switch result {
        case .success(let feed):
          self.handle(feed: feed)
          break
        case .failure(let error):
          print("Error parsing RSS feed", error)
        }
      })
    }))
  }
  
  func handle(feed: Feed) {
    if let rssFeed = feed.rssFeed {
      guard let clientFeed = ClientFeed.from(feed: rssFeed) else { return }
      DispatchQueue.main.async {
        JavaScriptBridge.instance.send(.fetchedFeed(feed: clientFeed))
      }
    }
  }
}

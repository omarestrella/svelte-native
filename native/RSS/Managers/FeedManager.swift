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
  var date: String
  var content: String
  var link: String

  static func from(item: RSSFeedItem) -> ClientFeedItem? {
    if let title = item.title,
       let description = item.description,
       let date = item.pubDate,
       let content = item.content?.contentEncoded,
       let link = item.link {
      return .init(title: title, description: description, date: date.formatted(.iso8601), content: content, link: link)
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
    JavaScriptBridge.instance.on(.fetchFeed) { (_ feedRequest: FeedRequest) in
      guard let feedURL = URL(string: feedRequest.url) else {
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
    }
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

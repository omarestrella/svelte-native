//
//  JSON.swift
//  RSS
//
//  Created by Omar Estrella on 8/31/22.
//

import Foundation

protocol ClientRequest: Decodable {}

struct ApplicationUpdateRequest: ClientRequest {
  enum UpdateType: Decodable {
    case title(newTitle: String)
    case subtitle(newSubtitle: String)
  }
  
  var update: UpdateType
}

struct FeedRequest: ClientRequest {
  var url: String
}

struct ClientLog: ClientRequest {
  var name: String
  var message: String?
}

enum ClientMessage {
  // MARK: Native
  case updateApplicationState(ApplicationUpdateRequest)
  
  // MARK: RSS
  case fetchFeed(FeedRequest)

  // MARK: Helpers
  case log(ClientLog)
  case error(message: String)
}

extension ClientMessage: Decodable {
  enum CodingKeys: CodingKey {
    case type
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)

    do {
      switch type {
      case "updateApplicationState":
        self = .updateApplicationState(try ApplicationUpdateRequest(from: decoder))
      case "fetchFeed":
        self = .fetchFeed(try FeedRequest(from: decoder))
      case "log":
        self = .log(try ClientLog(from: decoder))
      default:
        self = .error(message: "Encountered unknown type: \(type)")
      }
    } catch {
      self = .error(message: error.localizedDescription)
    }
  }
}

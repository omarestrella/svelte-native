//
//  JSON.swift
//  RSS
//
//  Created by Omar Estrella on 8/31/22.
//

import Foundation

enum ClientMessage {
  case registerShortcut(ClientShortcut)
  case removeShortcut(id: String)
  
  case updateApplicationState(ApplicationUpdate)

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
      case "registerShortcut":
        self = .registerShortcut(try ClientShortcut(from: decoder))
      case "removeShortcut":
        self = .removeShortcut(id: try Dictionary<String, String>(from: decoder)["id"]!)
      case "updateApplicationState":
        self = .updateApplicationState(try ApplicationUpdate(from: decoder))
      default:
        self = .error(message: "Encountered unknown type")
      }
    } catch {
      self = .error(message: error.localizedDescription)
    }
  }
}

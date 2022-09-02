//
//  ApplicationState.swift
//  RSS
//
//  Created by Omar Estrella on 9/1/22.
//

import Foundation

struct ApplicationUpdate: Decodable {
  enum UpdateType: Decodable {
    case title(newTitle: String)
    case subtitle(newSubtitle: String)
  }
  
  var update: UpdateType
}

//
//  Application.swift
//  RSS
//
//  Created by Omar Estrella on 9/1/22.
//

import Combine
import Foundation

class ApplicationModel: ObservableObject {
  @Published var title: String = ""
  @Published var subtitle: String = ""

  init() {
    registerEventHandlers()
  }

  func registerEventHandlers() {
    JavaScriptBridge.instance.on(.updateApplicationState, .init(handler: { message in
      guard case .updateApplicationState(let update) = message else {
        return
      }
      
      switch update.update {
      case .subtitle(let subtitle):
        self.subtitle = subtitle
        break
      case .title(let title):
        self.title = title
        break
      }
    }))
  }
}

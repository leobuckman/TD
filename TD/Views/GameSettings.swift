//
//  GameSettings.swift
//  RPS
//
//  Created by Leo Buckman on 12/12/23.
//

import Foundation
import SwiftUI

class GameSettings: ObservableObject {
    @Published var selectedStrikeCount: StrikesView.StrikeCount? = nil
}

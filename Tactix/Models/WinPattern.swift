//
//  WinPattern.swift
//  Tactix
//
//  Created by Hardik Kothari on 22.03.25.
//

import Foundation

enum GameResult: Equatable {
    static func == (lhs: GameResult, rhs: GameResult) -> Bool {
        switch (lhs, rhs) {
        case (.win , .win):
            return true
        case (.draw, .draw):
            return true
        case (.none, .none):
            return true
        default:
            return false
        }
    }
    
    case win(Player, WinPattern), draw, none
}

enum WinDirection: CaseIterable {
    case horizontal, vertical, forwardDiagnal, backwardDiagnal
}

struct WinPattern {
    var indexes: [Int]
    var direction: WinDirection
}

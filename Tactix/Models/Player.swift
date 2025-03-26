//
//  Player.swift
//  Tactix
//
//  Created by Hardik Kothari on 21.03.25.
//

import SwiftUI

class Player: ObservableObject, Equatable {
    @Published var id: PlayerId
    @Published var name: String
    @Published var marker: Marker
    @Published var markerColor: Color
    @Published var discColor: Color
    @Published var isBot: Bool
    
    init(id: PlayerId, name: String, marker: Marker, markerColor: Color, discColor: Color, isBot: Bool = false) {
        self.id = id
        self.name = name
        self.marker = marker
        self.markerColor = markerColor
        self.discColor = discColor
        self.isBot = isBot
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
}

enum Marker: String, CaseIterable {
    case x = "X"
    case o = "O"
}

enum PlayerId {
    case one, two
}

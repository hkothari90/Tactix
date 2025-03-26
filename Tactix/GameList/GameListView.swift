//
//  GameListView.swift
//  Tactix
//
//  Created by Hardik Kothari on 18.03.25.
//

import SwiftUI

enum Game: CaseIterable {
    case connectFour, ticTacToe
    
    var iconName: String {
        switch self {
        case .connectFour:
            return "ic_connect_four"
        case .ticTacToe:
            return "ic_tac_tic_toe"
        }
    }
    
    var title: String {
        switch self {
        case .connectFour:
            return "Connect Four"
        case .ticTacToe:
            return "Tic-Tac-Toe"
        }
    }
}

struct GameListView: View {
    @StateObject private var player1 = Player(id: .one, name: "MasterMind", marker: .x, markerColor: .blue, discColor: .red)
    @StateObject private var player2 = Player(id: .two, name: "TactixAce", marker: .o, markerColor: .red, discColor: .yellow, isBot: true)
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                List(Game.allCases, id: \.self) { game in
                    NavigationLink {
                        switch game {
                        case .connectFour:
                            CFGameView(viewModel: CFGameViewModel(player1: player1, player2: player2))
                        case .ticTacToe:
                            XOGameView(viewModel: XOGameViewModel(player1: player1, player2: player2))
                        }
                    } label: {
                        HStack(spacing: 16) {
                            Image(game.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                            
                            Text(game.title)
                                .font(.title3).fontWeight(.semibold)
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .listStyle(.grouped)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("Games")
                            .bold()
                            .font(.largeTitle)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            NavigationLink {
                                SettingsView(player1: player1, player2: player2)
                            } label: {
                                Image(systemName: "gear")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width/15, height: geometry.size.width/15)
                                    .padding(8)
                                    .background(.quaternary)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    GameListView()
}

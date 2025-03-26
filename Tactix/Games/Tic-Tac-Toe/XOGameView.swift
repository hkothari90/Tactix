//
//  XOGameView.swift
//  Tactix
//
//  Created by Hardik Kothari on 18.03.25.
//

import SwiftUI

struct XOGameView: View {
    @StateObject var viewModel: XOGameViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                HStack {
                    XOMarkerView(marker: viewModel.player1.marker, markerColor: viewModel.player1.markerColor)
                        .frame(width: geometry.size.width / 9, height: geometry.size.width / 9)
                        .cornerRadius(8)
                    
                    VStack {
                        HStack {
                            Text(viewModel.player1.name)
                            Spacer()
                            Text(viewModel.player2.name)
                        }
                        .font(.title3.bold())
                        
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(.yellow)
                            Text("\(viewModel.player1Score)")
                            Spacer()
                            Text("\(viewModel.player2Score)")
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                    
                    XOMarkerView(marker: viewModel.player2.marker, markerColor: viewModel.player2.markerColor)
                        .frame(width: geometry.size.width / 9, height: geometry.size.width / 9)
                        .cornerRadius(8)
                }
                .padding(.bottom, 24)

                ZStack {
                    LazyVGrid(columns: viewModel.columns, spacing: 6) {
                        ForEach(0..<9) { position in
                            let marker = viewModel.getMarker(for: position)
                            let markerColor = viewModel.getMarkerColor(for: position)
                            let winDirection = viewModel.getWinDirection(for: position)
                            XOMarkerView(marker: marker, markerColor: markerColor, winDirection: winDirection)
                                .frame(width: geometry.size.width / 3 - 14, height: geometry.size.width / 3 - 14)
                                .onTapGesture {
                                    viewModel.makeMove(at: position)
                                }
                        }
                    }
                    .background(.gray.opacity(0.8))
                    if viewModel.awaitingEngineMove {
                        ProgressView("Waiting...")
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
                .padding(.bottom, 24)
                
                HStack {
                    switch viewModel.result {
                    case .win(let player, _):
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        Spacer()
                        Text("\(player.name) wins!")
                        Spacer()
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                    case .draw:
                        Text("It's a Draw!")
                    case .none:
                        Text("\(viewModel.currentPlayer.name)'s turn")
                    }
                }
                .frame(maxWidth: .infinity)
                .font(.system(size: 26, design: .rounded).weight(.semibold))
                .multilineTextAlignment(.center)
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .background(.blue.opacity(0.15))
                .cornerRadius(10)
                
                if viewModel.result != .none {
                    Button {
                        viewModel.startGame()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            
                            Text("Play again!")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 8)
                    }
                    .font(.system(size: 26, design: .rounded).weight(.semibold))
                    .background(.blue.opacity(0.15))
                    .cornerRadius(10)
                    .tint(.black)
                }
            }
            .padding()
            .displayConfetti(isActive: $viewModel.showConfetti)
        }
        .navigationTitle("Tic-Tac-Toe")
    }
}

struct XOMarkerView: View {
    var marker: Marker?
    var markerColor: Color?
    var winDirection: WinDirection?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                
                VStack {
                    if let marker = marker, let markerColor = markerColor {
                        Text(marker.rawValue)
                            .font(.system(size: geometry.size.height * 0.75, design: .rounded).weight(.medium))
                            .foregroundStyle(markerColor)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(markerColor?.opacity(0.2) ?? .white)
                
                if let winDirection = winDirection {
                    Line(direction: winDirection)
                        .stroke(style: .init(lineWidth: 5))
                        .foregroundStyle(.gray.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    let player1 = Player(id: .one, name: "MasterMind", marker: .x, markerColor: .blue, discColor: .red)
    let player2 = Player(id: .two, name: "TactixAce", marker: .o, markerColor: .red, discColor: .yellow, isBot: true)
    XOGameView(viewModel: XOGameViewModel(player1: player1, player2: player2))
}

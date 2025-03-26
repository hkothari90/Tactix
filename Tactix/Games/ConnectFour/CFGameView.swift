//
//  CFGameView.swift
//  Tactix
//
//  Created by Hardik Kothari on 18.03.25.
//

import SwiftUI

struct CFGameView: View {
    @StateObject var viewModel: CFGameViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                HStack {
                    CFDiscView(discColor: viewModel.player1.discColor)
                        .frame(width: geometry.size.width / 9, height: geometry.size.width / 9)
                    
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
                    
                    CFDiscView(discColor: viewModel.player2.discColor)
                        .frame(width: geometry.size.width / 9, height: geometry.size.width / 9)
                }
                .padding(.bottom, 24)
                
                ZStack {
                    LazyVGrid(columns: viewModel.columns, spacing: 0) {
                        ForEach(0..<42) { position in
                            let discColor = viewModel.getDiscColor(for: position)
                            let winDirection = viewModel.getWinDirection(for: position)
                            CFDiscView(discColor: discColor, winDirection: winDirection)
                                .frame(width: geometry.size.width / 7.78, height: geometry.size.width / 7.78)
                                .onTapGesture {
                                    viewModel.dropDisc(in: position % 7)
                                }
                        }
                    }
                    if viewModel.awaitingEngineMove {
                        ProgressView("Waiting...")
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
                .padding(8)
                .background(.blue)
                .cornerRadius(12)
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
        .navigationTitle("Connect Four")
    }
}

struct CFDiscView: View {
    var discColor: Color?
    var winDirection: WinDirection?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(.black)
                    .padding(5)

                if let discColor = discColor {
                    Image(systemName: "opticaldisc.fill")
                        .font(.system(size: geometry.size.width - 10))
                        .foregroundStyle(discColor)
                }
                
                if let winDirection = winDirection {
                    Line(direction: winDirection)
                        .stroke(style: .init(lineWidth: 5))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    let player1 = Player(id: .one, name: "MasterMind", marker: .x, markerColor: .blue, discColor: .red)
    let player2 = Player(id: .two, name: "TactixAce", marker: .o, markerColor: .red, discColor: .yellow, isBot: true)
    CFGameView(viewModel: CFGameViewModel(player1: player1, player2: player2))
}

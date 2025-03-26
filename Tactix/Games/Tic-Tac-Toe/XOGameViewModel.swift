//
//  XOGameViewModel.swift
//  Tactix
//
//  Created by Hardik Kothari on 22.03.25.
//

import SwiftUI

final class XOGameViewModel: ObservableObject {
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    let player1: Player
    let player2: Player
    
    @Published var currentPlayer: Player!
    @Published var awaitingEngineMove = false
    @Published var result: GameResult = .none
    @Published var showConfetti: Bool = false
    @Published var player1Score: Int = 0
    @Published var player2Score: Int = 0
    
    private var board = [PlayerId?]()
    private var engine = XOEngine()
    
    init(player1: Player, player2: Player) {
        self.player1 = player1
        self.player2 = player2
        startGame()
    }
    
    func startGame() {
        board = Array(repeating: nil, count: 9)
        currentPlayer = player1
        result = .none
        showConfetti = false
    }
    
    func makeMove(at position: Int) {
        guard result == .none, board[position] == nil else { return }
        board[position] = currentPlayer.id
        checkForResult()
    }
    
    private func checkForResult() {
        if let winPattern = engine.checkWin(for: currentPlayer, onBoard: board) {
            adjustScoreAndHighlightWin(winPattern)
        } else if engine.checkDraw(on: board) {
            result = .draw
        } else {
            toggleTurn()
        }
    }
    
    private func toggleTurn() {
        currentPlayer = currentPlayer == player1 ? player2 : player1
        if currentPlayer.isBot {
            makeEngineMove()
        }
    }
    
    private func makeEngineMove() {
        awaitingEngineMove = true
        Task {
            let position = await engine.findBestMovePosition(for: currentPlayer, onBoard: board)
            await MainActor.run {
                makeMove(at: position)
                awaitingEngineMove = false
            }
        }
    }
    
    private func adjustScoreAndHighlightWin(_ pattern: WinPattern) {
        currentPlayer == player1 ? (player1Score += 1) : (player2Score += 1)
        showConfetti = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
            showConfetti = false
        }
        var indexToHighlight = [Int]()
        for i in 0..<pattern.indexes.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(i)) { [self] in
                indexToHighlight.append(pattern.indexes[i])
                result = .win(currentPlayer, WinPattern(indexes: indexToHighlight, direction: pattern.direction))
            }
        }
    }
}

// Gets data for the Marker
extension XOGameViewModel {
    func getMarker(for position: Int) -> Marker? {
        guard let playerId = board[position] else { return nil }
        return player1.id == playerId ? player1.marker : player2.marker
    }
    
    func getMarkerColor(for position: Int) -> Color? {
        guard let playerId = board[position] else { return nil }
        return player1.id == playerId ? player1.markerColor : player2.markerColor
    }
    
    func getWinDirection(for position: Int) -> WinDirection? {
        switch result {
        case .win(_, let pattern):
            guard pattern.indexes.contains(position) else { return nil }
            return pattern.direction
        default:
            return nil
        }
    }
}

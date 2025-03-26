//
//  CFGameViewModel.swift
//  Tactix
//
//  Created by Hardik Kothari on 18.03.25.
//

import SwiftUI

class CFGameViewModel: ObservableObject {
    let columns = Array(repeating: GridItem(), count: 7)
    let player1: Player
    let player2: Player
    
    @Published var board = [PlayerId?]()
    @Published var currentPlayer: Player!
    @Published var awaitingEngineMove = false
    @Published var result: GameResult = .none
    @Published var showConfetti: Bool = false
    @Published var player1Score: Int = 0
    @Published var player2Score: Int = 0
    
    private var engine = CFEngine()
    
    init(player1: Player, player2: Player) {
        self.player1 = player1
        self.player2 = player2
        startGame()
    }
    
    func startGame() {
        board = Array(repeating: nil, count: 42)
        currentPlayer = player1
        result = .none
        showConfetti = false
    }
    
    func dropDisc(in column: Int) {
        guard result == .none, board[column] == nil else { return }
        var emptyRows = 0
        while emptyRows < 5, board[7*emptyRows + column] == nil, board[(7 * (emptyRows + 1)) + column] == nil {
            emptyRows += 1
        }
        
        for row in 0...emptyRows {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12*Double(row)) { [self] in
                if row > 0 {
                    board[(7 * (row - 1)) + column] = nil
                }
                board[7 * row + column] = currentPlayer.id
                if row == emptyRows {
                    checkForResult()
                }
            }
        }
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
                dropDisc(in: position % 7)
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

// Gets data for the disc
extension CFGameViewModel {
    func getDiscColor(for position: Int) -> Color? {
        guard let playerId = board[position] else { return nil }
        return player1.id == playerId ? player1.discColor : player2.discColor
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

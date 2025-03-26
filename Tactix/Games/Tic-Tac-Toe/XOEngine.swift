//
//  XOEngine.swift
//  Tactix
//
//  Created by Hardik Kothari on 20.03.25.
//

import Foundation

final class XOEngine {
    func checkWin(for player: Player, onBoard board: [PlayerId?]) -> WinPattern? {
        for i in 0..<3 {
            if board[i*3] == player.id, board[i*3+1] == player.id, board[i*3+2] == player.id {
                return WinPattern(indexes: [i*3, i*3+1, i*3+2], direction: .horizontal)
            }
            
            if board[i] == player.id, board[i+3] == player.id, board[i+6] == player.id {
                return WinPattern(indexes: [i, i+3, i+6], direction: .vertical)
            }
        }
        // Diagonal Win
        if board[0] == player.id, board[4] == player.id, board[8] == player.id {
            return WinPattern(indexes: [0, 4, 8], direction: .backwardDiagnal)
        }
        if board[2] == player.id, board[4] == player.id, board[6] == player.id {
            return WinPattern(indexes: [2, 4, 6], direction: .forwardDiagnal)
        }
        return nil
    }
    
    func checkDraw(on board: [PlayerId?]) -> Bool {
        return !board.contains(nil)
    }
    
    func findBestMovePosition(for player: Player, onBoard board: [PlayerId?]) async -> Int {
        let winSequences: Set<Set<Int>> = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]
        
        // Step 1: If player can win on this move
        let playerPositions = Set(board.enumerated().compactMap { (index, element) in
            element == player.id ? index : nil
        })
        for sequence in winSequences {
            let winPositions = sequence.subtracting(playerPositions)
            if winPositions.count == 1 {
                if board[winPositions.first!] == nil {
                    return winPositions.first!
                }
            }
        }
        
        // Step 2: If player can't win, find opponent win position and block
        let opponentPositions = Set(board.enumerated().compactMap { (index, element) in
            (element != nil && element != player.id) ? index : nil
        })
        for sequence in winSequences {
            let winPositions = sequence.subtracting(opponentPositions)
            if winPositions.count == 1 {
                if board[winPositions.first!] == nil {
                    return winPositions.first!
                }
            }
        }
        
        // Step 3: If can't win, and can't block or no opponent win position, then take center position if available
        let centerIndex = 4
        if board[centerIndex] == nil {
            return centerIndex
        }
        
        //Step 4: If can't take the center position, take any available square
        return board.firstIndex(of: nil)!
    }
}

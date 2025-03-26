//
//  CFEngine.swift
//  Tactix
//
//  Created by Hardik Kothari on 21.03.25.
//

import Foundation

final class CFEngine {
    private var allWinPossibilities: Set<Set<Int>> = []
    
    init () {
        allWinPossibilities = findAllWinPossibilities()
    }
    
    private func findAllWinPossibilities() -> Set<Set<Int>> {
        let rows = 6
        let cols = 7
        var winCombinations: Set<Set<Int>> = []
        
        // Horizontal wins
        for r in 0..<rows {
            for c in 0..<(cols - 3) {
                winCombinations.insert(Set((0..<4).map { (r * cols) + c + $0 }))
            }
        }
        
        // Vertical wins
        for r in 0..<(rows - 3) {
            for c in 0..<cols {
                winCombinations.insert(Set((0..<4).map { (r * cols) + c + ($0 * cols) }))
            }
        }
        
        // Diagonal wins (left-to-right)
        for r in 0..<(rows - 3) {
            for c in 0..<(cols - 3) {
                winCombinations.insert(Set((0..<4).map { (r * cols) + ($0 * cols) + (c + $0) }))
            }
        }
        
        // Diagonal wins (right-to-left)
        for r in 0..<(rows - 3) {
            for c in 3..<cols {
                winCombinations.insert(Set((0..<4).map { (r * cols) + ($0 * cols) + (c - $0) }))
            }
        }
        
        return winCombinations
    }
    
    func checkWin(for player: Player, onBoard board: [PlayerId?]) -> WinPattern? {
        guard let horizontalSequence = checkHorizontalWin(for: player, onBoard: board) else {
            guard let verticalSequence = checkVerticalWin(for: player, onBoard: board) else {
                guard let diagonalSequence = checkDiagonalWin(for: player, onBoard: board) else {
                    return nil
                }
                return diagonalSequence
            }
            return verticalSequence
        }
        return horizontalSequence
    }
    
    private func checkHorizontalWin(for player: Player, onBoard board: [PlayerId?]) -> WinPattern? {
        for row in 0...5 {
            for col in 0...3 {
                if board[7 * row + col] == player.id,
                   board[7 * row + col + 1] == player.id,
                   board[7 * row + col + 2] == player.id,
                   board[7 * row + col + 3] == player.id {
                    return WinPattern(indexes: [(7 * row + col),
                                                (7 * row + col + 1),
                                                (7 * row + col + 2),
                                                (7 * row + col + 3)], direction: .horizontal)
                }
            }
        }
        return nil
    }
    
    private func checkVerticalWin(for player: Player, onBoard board: [PlayerId?]) -> WinPattern? {
        for row in 0...2 {
            for col in 0...6 {
                if board[7 * row + col] == player.id,
                   board[7 * row + col + 7] == player.id,
                   board[7 * row + col + 14] == player.id,
                   board[7 * row + col + 21] == player.id {
                    return WinPattern(indexes: [(7 * row + col),
                                                (7 * row + col + 7),
                                                (7 * row + col + 14),
                                                (7 * row + col + 21)], direction: .vertical)
                }
            }
        }
        return nil
    }
    
    private func checkDiagonalWin(for player: Player, onBoard board: [PlayerId?]) -> WinPattern? {
        for row in 0...2 {
            for col in 0...3 {
                if board[7 * row + col] == player.id,
                   board[7 * row + col + 8] == player.id,
                   board[7 * row + col + 16] == player.id,
                   board[7 * row + col + 24] == player.id {
                    return WinPattern(indexes: [(7 * row + col),
                                                (7 * row + col + 8),
                                                (7 * row + col + 16),
                                                (7 * row + col + 24)], direction: .backwardDiagnal)
                }
            }
            for col in 3...6 {
                if board[7 * row + col] == player.id,
                   board[7 * row + col + 6] == player.id,
                   board[7 * row + col + 12] == player.id,
                   board[7 * row + col + 18] == player.id {
                    return WinPattern(indexes: [(7 * row + col),
                                                (7 * row + col + 6),
                                                (7 * row + col + 12),
                                                (7 * row + col + 18)], direction: .forwardDiagnal)
                }
            }
        }
        return nil
    }
    
    func checkDraw(on board: [PlayerId?]) -> Bool {
        return !board.contains(nil)
    }
    
    func findBestMovePosition(for player: Player, onBoard board: [PlayerId?]) async -> Int {
        // Step 1: If player can win on this move
        let playerPositions = Set(board.enumerated().compactMap { (index, element) in
            element == player.id ? index : nil
        })
        for winPossibility in allWinPossibilities {
            let winPositions = winPossibility.subtracting(playerPositions)
            if winPositions.count == 1 {
                if let winPosition = winPositions.first, isWinPositionTopMostEmptyPosition(winPosition, onBoard: board) {
                    return winPosition
                }
            }
        }
        
        // Step 2: If player can't win, find opponent win position and block
        let opponentPositions = Set(board.enumerated().compactMap { (index, element) in
            (element != nil && element != player.id) ? index : nil
        })
        for winPossibility in allWinPossibilities {
            let winPositions = winPossibility.subtracting(opponentPositions)
            if winPositions.count == 1 {
                if let winPosition = winPositions.first, isWinPositionTopMostEmptyPosition(winPosition, onBoard: board) {
                    return winPosition
                }
            }
        }
        
        // Step 3: If can't win, and can't block or no opponent win position, then take center position if available
        var col = Int.random(in: 0...6)
        while (board[col] != nil) {
            col = Int.random(in: 0...6)
        }
        return col
    }
    
    private func isWinPositionTopMostEmptyPosition(_ position: Int, onBoard board: [PlayerId?]) -> Bool {
        guard board[position] == nil else { return false }
        var topIdx = position % 7
        var topEmptyRow = 0
        while (board[topIdx] == nil && topIdx+7 <= 41 && board[topIdx+7] == nil) {
            topEmptyRow += 1
            topIdx += 7
        }
        return (topEmptyRow == Int(position / 7))
    }
}

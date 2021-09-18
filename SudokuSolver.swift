//
//  SudokuSolver.swift
//  SudokuSolver
//
//  Created by Carlos McNulty on 9/16/21.
//

import Foundation

struct SudokuSolver{
    
    let DIGITS = 9
    let CELLS = 81
    
    var units: [Set<Int>] = []
    var peers: [Set<Int>] = []
    var values: [Set<Int>] = []
    
    init() {
        // Get all rows
        for i in 0..<DIGITS {
            var row = Set<Int>()
            for j in 0..<DIGITS {
                row.insert(DIGITS*i + j)
            }
            units.append(row)
        }
        // Get all columns
        for i in 0..<DIGITS {
            var column = Set<Int>()
            for j in 0..<DIGITS {
                column.insert(DIGITS*j + i)
            }
            units.append(column)
        }
        // Get all blocks
        for i in stride(from: 0, to: DIGITS, by: 3) {
            for j in stride(from: 0, to: DIGITS, by: 3) {
                var block = Set<Int>()
                // Step through all values in block
                for r in i..<i+3 {
                    for c in j..<j+3 {
                        block.insert(DIGITS*r + c)
                    }
                }
                units.append(block)
            }
        }
        // Set peers for each cell in board
        for i in 0..<CELLS {
            var conflicts = Set<Int>()
            // Get all conflicting peers for current cell
            for unit in units {
                if unit.contains(i) {
                    conflicts.formUnion(unit)
                    // Exclude self from peers
                    conflicts.remove(i)
                }
            }
            peers.append(conflicts)
        }
    }
    
    func isSolved(_ values: [Set<Int>]) -> Bool {
        for vals in values {
            if vals.count != 1 {
                return false
            }
        }
        return true
    }
    
    func minConstraints(_ values: [Set<Int>]) -> Int {
        // Choose cell for search with fewest constraints
        var cell = 0
        var size = DIGITS
        for i in 0..<CELLS {
            // Select unsolved cell with fewest constraints
            if values[i].count > 1
                && values[i].count <= size {
                cell = i
                size = values[i].count
            }
        }
        return cell
    }
    
    func assign(_ values: inout [Set<Int>], _ cell: Int, _ digit: Int) -> Bool {
        // Eliminate all remaining possible values from cell and leave just assigned digit
        let vals = values[cell]
        for d in vals {
            if d != digit {
                if !eliminate(&values, cell, d) {
                    return false
                }
            }
        }
        return true
    }
    
    func eliminate(_ values: inout [Set<Int>], _ cell: Int,  _ digit: Int) -> Bool {
        // Check if digit has already been eliminated
        if !values[cell].contains(digit) {
            return true
        }
        values[cell].remove(digit)
        // Incorrect solution found, propagate failure
        if values[cell].count == 0 {
            return false
        }
        // Solution to cell found
        if values[cell].count == 1 {
            // Solved cell value
            let d = values[cell].first!
            // Eliminate solved cell value from peers (conflicting cells)
            for peer in peers[cell] {
                // If solution is incorrect then propagate failure
                if !eliminate(&values, peer, d) {
                    return false
                }
            }
        }
        
        for u in units {
            if u.contains(cell) {
                // Find all cells where digit is possible in unit
                var possibleCells: [Int] = []
                for cell in u {
                    if values[cell].contains(digit) {
                        possibleCells.append(cell)
                    }
                }
                // If digit can't go anywhere in unit then solution is incorrect
                if possibleCells.count == 0 {
                    return false
                }
                // If digit has only one cell as possibility then assign
                if possibleCells.count == 1 {
                    // Check for propagated failure
                    if !assign(&values, possibleCells.first!, digit) {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    func search(_ values: inout [Set<Int>], _ level: Int) -> Optional<[Int]> {
        if isSolved(values) {
            // Get solution from constraints
            var solution: [Int] = []
            for vals in values {
                solution.append(vals.first!)
            }
            return solution
        }
        // Choose cell with fewest constraints for search
        let minCell = minConstraints(values)
        // Attempt to assign each remaining value to cell
        for d in values[minCell] {
            // Use copied version of values for search
            var searchVals = values
            // Check if assign violates any constraints
            if assign(&searchVals, minCell, d) {
                // Continue search on this branch if successfully assigned
                let solution = search(&searchVals, level+1)
                if solution != nil {
                    return solution
                }
            }
        }
        return nil
    }
    
    mutating func solve(board: [Int]) -> Optional<[Int]> {
        if board.count != CELLS {
            return nil
        }
        
        // Each cell is default to possible values [1,9]
        values = []
        for _ in 0..<CELLS {
            values.append(Set(1...9))
        }
        
        // Assign known values to board
        for i in 0..<CELLS {
            if board[i] != 0 {
                if !assign(&values, i, board[i]) {
                    return nil
                }
            }
        }
        // Use search to solve remaining unsolved cells
        return search(&values, 0)
    }
}

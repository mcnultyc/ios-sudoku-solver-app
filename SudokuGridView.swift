//
//  SudokuGridView.swift
//  SudokuSolverApp
//
//  Created by Carlos McNulty on 9/18/21.
//

import SwiftUI

struct SudokuGridView: View {
    
    var value = 0
    @State var board: [Int] =
        [0,0,0,   6,0,2,   8,0,4,
         0,4,0,   0,3,0,   0,0,7,
         8,2,0,   0,0,0,   0,0,0,
         4,0,6,   0,5,0,   3,0,0,
         2,0,8,   0,0,0,   0,0,0,
         0,0,0,   0,0,0,   9,1,0,
         1,0,0,   0,0,0,   2,0,0,
         0,7,0,   9,0,0,   0,5,0,
         0,0,2,   4,0,0,   0,0,8]
    
    @State var selectedCell = -1
    
    @State var solvedCells: Set<Int> = Set<Int>()
    
    func getColor(_ i: Int) -> Color {
        if selectedCell == i {
            return Color(red: 0.4627, green: 0.8392, blue: 1.0)
        }
        if solvedCells.contains(i) {
            return Color(red: 0.96, green: 0.86, blue: 0.60)
        }
        return Color.white
    }
    
    var body: some View {
        
        VStack{
            
            Text("Sudoku Solver")
                .font(.custom("chalkduster", size: 35))
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(25)), count: 9), spacing: 0) {
                ForEach(0..<board.count) { i in
                    if board[i] == 0 {
                        Button(action: {
                            selectedCell = i
                        }) {
                            Image("blank")
                                .resizable()
                                .frame(width: 15, height: 25, alignment: .center)
                                .padding(10)
                                .border(Color.black)
                        }
                        .background(getColor(i))


                    }
                    else {
                        Button(action: {
                            selectedCell = i
                        }) {
                            Image(String(board[i]))
                                .resizable()
                                .frame(width: 15, height: 25, alignment: .center)
                                .padding(10)
                                .border(Color.black)
                        }
                        .background(getColor(i))
                    }
                }
            }
            HStack{
                ForEach(1...9, id: \.self) { i in
                    Button(action: {
                        if selectedCell != -1 {
                            board[selectedCell] = i
                        }
                        
                    }) {
                        Image(String(i))
                            .resizable()
                            .frame(width: 15, height: 25, alignment: .center)
                            .padding(5)
                            .border(Color.black)
                    }
                }
            }
            .padding(.top, 7)
            
            HStack {

                Button(action: {
                    let numAssigned = board.filter{$0 != 0}.count
                    if numAssigned > 15 {
                        solvedCells = Set<Int>()
                        for i in 0..<board.count {
                            if board[i] == 0 {
                                solvedCells.insert(i)
                            }
                        }
                        
                        var sudokuSolver = SudokuSolver()
                        let solution = sudokuSolver.solve(board: board)
                        if solution != nil {
                            board = solution!
                        }
                    }
                    
                }) {
                    HStack{
                        Image("robot")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .center)
                        Text("Solve")
                            .foregroundColor(.black)
                            .font(.custom("chalkduster", size: 20))
                    }
                    .padding(5)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 1))
                }
                .padding(.top, 10)
            }
            
            Button(action: {
                board = Array(repeating: 0, count: 81)
                solvedCells = Set<Int>()
            }) {
                Text("Clear")
                    .foregroundColor(.black)
                    .font(.custom("chalkduster", size: 15))
                    .padding(2)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 1))
            }
            .padding(.top, 10)

        }
    }
}

struct SudokuGridView_Previews: PreviewProvider {
    static var previews: some View {
        SudokuGridView()
    }
}

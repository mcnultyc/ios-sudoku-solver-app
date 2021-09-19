//
//  SudokuGridView.swift
//  SudokuSolverApp
//
//  Created by Carlos McNulty on 9/18/21.
//

import SwiftUI

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {

    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

struct SudokuGridView: View {
    
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
    
    @State var showPopUp: Bool = false
    
    func getBorderWidth(_ i: Int) -> CGFloat {
        // Border thicker on edge of blocks
        if i % 3 == 0 {
            return 3
        }
        return 0.75
    }
    
    func getIndex(_ r: Int, _ c: Int) -> Int {
        // Get board index
        return 9 * (r - 1) + (c - 1)
    }
    
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
        ZStack {
            VStack{
                Text("Sudoku Solver")
                    .font(.custom("chalkduster", size: 35))
                
                VStack(spacing: 0) {
                    ForEach(1...9, id: \.self) { i in
                        HStack(spacing: 0) {
                            ForEach(1...9, id: \.self) { j in
                                let index = getIndex(i, j)
                                if board[index] == 0 {
                                    Button(action: {
                                        selectedCell = index
                                    }) {
                                        Image("blank")
                                            .resizable()
                                            .frame(width: 15, height: 25, alignment: .center)
                                            .padding(10)
                                            .border(width: getBorderWidth(j), edges: [.trailing], color: .black)
                                            .background(getColor(index))
                                    }
                                }
                                else{
                                    Button(action: {
                                        selectedCell = index
                                    }) {
                                        Image(String(board[index]))
                                            .resizable()
                                            .frame(width: 15, height: 25, alignment: .center)
                                            .padding(10)
                                            .border(width: getBorderWidth(j), edges: [.trailing], color: .black)
                                            .background(getColor(index))
                                    }
                                }
                            }
                        }
                        .border(width: getBorderWidth(i), edges: [.bottom], color: .black)
                    }
                }
                .border(Color.black, width: 3)
                
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
                
                Button(action: {
                    // Store cells that will be solved by algorithm
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
                    else {
                        solvedCells = Set<Int>()
                        showPopUp.toggle()
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
            
            NoSolutionPopUpView(show: $showPopUp)
        }
    }
}

struct SudokuGridView_Previews: PreviewProvider {
    static var previews: some View {
        SudokuGridView()
    }
}

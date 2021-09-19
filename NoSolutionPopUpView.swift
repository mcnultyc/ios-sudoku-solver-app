//
//  PopUpView.swift
//  SudokuSolverApp
//
//  Created by Carlos McNulty on 9/18/21.
//

import SwiftUI

struct NoSolutionPopUpView: View {
    
    @Binding var show: Bool
    
    var body: some View {
        ZStack {
            if show {
                VStack {
                    HStack{
                        Image("robot")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .center)
                        Text("No solution found!")
                            .font(.custom("chalkduster", size: 20))
                    }
                    Button(action: {
                        withAnimation(.linear(duration: 0.3)) {
                            show = false
                        }
                    }) {
                        Text("Ok")
                            .foregroundColor(.black)
                            .font(.custom("chalkduster", size: 20))
                            .padding(2)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 1))
                    }
                }
                .padding(10)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 1))
            }
        }
    }
}

struct PopUpView_Previews: PreviewProvider {
    static var previews: some View {
        NoSolutionPopUpView(show: .constant(true))
    }
}

//
//  CustomNumberPadView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct KeyboardState: View {
    var focus: Binding<Bool>

    var body: some View {
        Button(action: {
            focus.wrappedValue = false
        }, label: {
            Image(systemName: "keyboard.chevron.compact.down")
                .font(.footnote)
        } )
        .disabled(focus.wrappedValue == false)
    }
}

struct CustomNumberPadView: View {
    @Binding var input: String
    
    let numbers = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "✔️"]
    ]
    
    var body: some View {
        VStack {
            Text(input)
                .font(.largeTitle)
                .padding()
            
            ForEach(numbers, id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { number in
                        Button(action: {
                            self.handleInput(number)
                        }) {
                            Text(number)
                                .font(.largeTitle)
                                .frame(width: 80, height: 80)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
    
    private func handleInput(_ number: String) {
        if number == "✔️" {
            // Perform action when done
            log.trace("Submit: \(input)")
        } else {
            input += number
        }
    }
}

// #Preview {
//    CustomNumberPadView()
// }

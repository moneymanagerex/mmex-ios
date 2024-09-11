//
//  PayeeEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import SwiftUI

struct PayeeEditView: View {
    @Binding var payee: Payee
    
    var body: some View {
        Form {
            Section(header: Text("Payee Name")) {
                TextField("Payee Name", text: $payee.name)
            }
        }
    }
}

#Preview {
    PayeeEditView(payee: .constant(Payee.sampleData[0]))
}

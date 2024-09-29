//
//  CurrencyEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/17.
//

import SwiftUI

struct CurrencyEditView: View {
    @Binding var currency: CurrencyData

    var body: some View {
        Form {
            Section(header: Text("Currency Name")) {
                TextField("Currency Name", text: $currency.name)
            }
            Section(header: Text("Prefix Symbol")) {
                TextField("Prefix Symbol", text: Binding(
                    get: { currency.prefixSymbol },
                    set: { currency.prefixSymbol = $0 }
                ))
            }
            Section(header: Text("Suffix Symbol")) {
                TextField("Suffix Symbol", text: Binding(
                    get: { currency.suffixSymbol },
                    set: { currency.suffixSymbol = $0 }
                ))
            }
            Section(header: Text("Scale")) {
                TextField("Scale", value: $currency.scale, format: .number)
            }
            Section(header: Text("Conversion Rate")) {
                TextField("Conversion Rate", value: $currency.baseConvRate, format: .number)
            }
            Section(header: Text("Currency Type")) {
                Picker("Currency Type", selection: $currency.type) {
                    ForEach(CurrencyType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .labelsHidden()
                .pickerStyle(SegmentedPickerStyle()) // Adjust the style of the picker as needed
            }
        }
    }
}

#Preview {
    CurrencyEditView(
        currency: .constant(CurrencyData.sampleData[0])
    )
}

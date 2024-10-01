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
            Section(header: Text("Name")) {
                TextField("Currency Name", text: $currency.name)
            }
            Section(header: Text("Symbol")) {
                TextField("Currency Symbol", text: $currency.symbol)
            }
            Section(header: Text("Unit Name")) {
                TextField("Unit Name", text: $currency.unitName)
            }
            Section(header: Text("Cent Name")) {
                TextField("Cent Name", text: $currency.centName)
            }

            Section(header: Text("Prefix Symbol")) {
                TextField("Prefix Symbol", text: $currency.prefixSymbol)
            }
            Section(header: Text("Suffix Symbol")) {
                TextField("Suffix Symbol", text: $currency.suffixSymbol)
            }
            Section(header: Text("Decimal Point")) {
                TextField("Decimal Point", text: $currency.decimalPoint)
            }
            Section(header: Text("Thousands separator")) {
                TextField("Thousand separator", text: $currency.groupSeparator)
            }
            Section(header: Text("Scale")) {
                TextField("Scale", value: $currency.scale, format: .number)
            }

            Section(header: Text("Conversion Rate")) {
                TextField("Conversion Rate", value: $currency.baseConvRate, format: .number)
            }
            Section(header: Text("Type")) {
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

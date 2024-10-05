//
//  CurrencyEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/17.
//  Edited 2024-10-05 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct CurrencyEditView: View {
    @EnvironmentObject var env: EnvironmentManager
    @Binding var currency: CurrencyData
    @State var edit: Bool
    var onDelete: () -> Void = { }

    var format: String {
        let amount: Double = 12345.67
        return amount.formatted(by: currency.formatter)
    }

    var body: some View {
        return Form {
            Section {
                env.theme.field.text(edit, "Name") {
                    TextField("Currency Name", text: $currency.name)
                        .textInputAutocapitalization(.sentences)
                }
                env.theme.field.text(edit, "Symbol") {
                    TextField("Currency Symbol", text: $currency.symbol)
                        .textInputAutocapitalization(.characters)
                }
                env.theme.field.picker(edit, "Type") {
                    Picker("", selection: $currency.type) {
                        ForEach(CurrencyType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                } selected: {
                    Text(currency.type.rawValue)
                }
                
                if edit || !currency.unitName.isEmpty {
                    env.theme.field.text(edit, "Unit Name") {
                        TextField("Unit Name", text: $currency.unitName)
                            .textInputAutocapitalization(.sentences)
                    }
                    if edit || !currency.centName.isEmpty {
                        env.theme.field.text(edit, "Cent Name") {
                            TextField("Cent Name", text: $currency.centName)
                                .textInputAutocapitalization(.sentences)
                        }
                    }
                }

                env.theme.field.text(edit, "Conversion Rate") {
                    TextField("Conversion Rate", value: $currency.baseConvRate, format: .number)
                }
            }

            Section {
                env.theme.field.text(edit, "Format") {
                    Text(format)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                if edit {
                    env.theme.field.text(edit, "Prefix Symbol") {
                        TextField("Prefix Symbol", text: $currency.prefixSymbol)
                            .textInputAutocapitalization(.characters)
                    }
                    env.theme.field.text(edit, "Suffix Symbol") {
                        TextField("Suffix Symbol", text: $currency.suffixSymbol)
                            .textInputAutocapitalization(.characters)
                    }
                    env.theme.field.text(edit, "Decimal Point") {
                        TextField("Decimal Point", text: $currency.decimalPoint)
                    }
                    env.theme.field.text(edit, "Thousands Separator") {
                        TextField("Thousands Separator", text: $currency.groupSeparator)
                    }
                    env.theme.field.text(edit, "Scale") {
                        TextField("Scale", value: $currency.scale, format: .number)
                    }
                }
            }

            // delete currency if not in use
            if env.currencyCache[currency.id] == nil {
                Button("Delete Currency") {
                    onDelete()
                }
                .foregroundColor(.red)
            }
        }
        .textSelection(.enabled)
    }
}

#Preview {
    CurrencyEditView(
        currency: .constant(CurrencyData.sampleData[0]),
        edit: false
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview {
    CurrencyEditView(
        currency: .constant(CurrencyData.sampleData[0]),
        edit: true
    )
    .environmentObject(EnvironmentManager.sampleData)
}

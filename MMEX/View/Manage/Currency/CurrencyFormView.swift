//
//  CurrencyFormView.swift
//  MMEX
//
//  2024-09-17: Created by Lisheng Guan
//  2024-10-05: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct CurrencyFormView: View {
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @Binding var data: CurrencyData
    @State var edit: Bool

    var format: String {
        let amount: Double = 12345.67
        return amount.formatted(by: data.formatter)
    }

    var body: some View {
        Section {
            env.theme.field.view(edit, "Name", editView: {
                TextField("Shall not be empty!", text: $data.name)
                    .keyboardType(env.theme.textPad)
                    .textInputAutocapitalization(.sentences)
            }, showView: {
                env.theme.field.valueOrError("Shall not be empty!", text: data.name)
            } )
            
            env.theme.field.view(edit, "Symbol", editView: {
                TextField("Shall not be empty!", text: $data.symbol)
                    .keyboardType(env.theme.textPad)
                    .textInputAutocapitalization(.characters)
            }, showView: {
                env.theme.field.valueOrError("Shall not be empty!", text: data.symbol)
            } )

            env.theme.field.view(edit, false, "Type", editView: {
                Picker("", selection: $data.type) {
                    ForEach(CurrencyType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }, showView: {
                Text(data.type.rawValue)
            } )

            if edit || !data.unitName.isEmpty || !data.centName.isEmpty {
                env.theme.field.view(edit, "Unit Name", valueView: {
                    TextField("N/A", text: $data.unitName)
                        .keyboardType(env.theme.textPad)
                        .textInputAutocapitalization(.sentences)
                } )

                env.theme.field.view(edit, "Cent Name", valueView: {
                    TextField("N/A", text: $data.centName)
                        .keyboardType(env.theme.textPad)
                        .textInputAutocapitalization(.sentences)
                } )
            }

            env.theme.field.view(edit, true, "Conversion Rate", editView: {
                TextField("Default is 1", value: $data.baseConvRate.defaultOne, format: .number)
                    .keyboardType(env.theme.decimalPad)
            }, showView: {
                Text("\(data.baseConvRate)")
            } )
        }
        
        Section("Format") {
            env.theme.field.view(false, "", valueView: {
                Text(format)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.gray)
            } )

            if edit {
                env.theme.field.view(edit, "Prefix Symbol") {
                    TextField("N/A", text: $data.prefixSymbol)
                        .keyboardType(env.theme.textPad)
                        .textInputAutocapitalization(.characters)
                }
                env.theme.field.view(edit, "Suffix Symbol") {
                    TextField("N/A", text: $data.suffixSymbol)
                        .keyboardType(env.theme.textPad)
                        .textInputAutocapitalization(.characters)
                }
                env.theme.field.view(edit, "Decimal Point") {
                    TextField("N/A", text: $data.decimalPoint)
                        .keyboardType(env.theme.textPad)
                }
                env.theme.field.view(edit, "Thousands Separator") {
                    TextField("N/A", text: $data.groupSeparator)
                        .keyboardType(env.theme.textPad)
                }
                env.theme.field.view(edit, true, "Scale", editView: {
                    TextField("Default is 1", value: $data.scale.defaultOne, format: .number)
                        .keyboardType(env.theme.decimalPad)
                }, showView: {
                    Text("\(data.scale)")
                } )
            }
        }
    }
}

#Preview("\(CurrencyData.sampleData[0].symbol) (show)") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { CurrencyFormView(
        vm: vm,
        data: .constant(CurrencyData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(env)
}

#Preview("\(CurrencyData.sampleData[0].symbol) (edit)") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { CurrencyFormView(
        vm: vm,
        data: .constant(CurrencyData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(env)
}

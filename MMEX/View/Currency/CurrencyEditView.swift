//
//  CurrencyEditView.swift
//  MMEX
//
//  2024-09-17: Created by Lisheng Guan
//  2024-10-05: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct CurrencyEditView: View {
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
            env.theme.field.text(edit, "Name") {
                TextField("Cannot be empty!", text: $data.name)
                    .textInputAutocapitalization(.sentences)
            } show: {
                env.theme.field.valueOrError("Cannot be empty!", text: data.name)
            }
            
            env.theme.field.text(edit, "Symbol") {
                TextField("Cannot be empty!", text: $data.symbol)
                    .textInputAutocapitalization(.characters)
            } show: {
                env.theme.field.valueOrError("Cannot be empty!", text: data.symbol)
            }
            
            env.theme.field.picker(edit, "Type") {
                Picker("", selection: $data.type) {
                    ForEach(CurrencyType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            } show: {
                Text(data.type.rawValue)
            }
            
            if edit || !data.unitName.isEmpty {
                env.theme.field.text(edit, "Unit Name") {
                    TextField("N/A", text: $data.unitName)
                        .textInputAutocapitalization(.sentences)
                }
                
                if edit || !data.centName.isEmpty {
                    env.theme.field.text(edit, "Cent Name") {
                        TextField("N/A", text: $data.centName)
                            .textInputAutocapitalization(.sentences)
                    }
                }
            }
            
            env.theme.field.text(edit, "Conversion Rate") {
                TextField("Default is 0", value: $data.baseConvRate, format: .number)
                    .keyboardType(.decimalPad)
            }
        }
        
        Section {
            env.theme.field.text(edit, "Format") {
                Text(format)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.gray)
            }
            if edit {
                env.theme.field.text(edit, "Prefix Symbol") {
                    TextField("N/A", text: $data.prefixSymbol)
                        .textInputAutocapitalization(.characters)
                }
                env.theme.field.text(edit, "Suffix Symbol") {
                    TextField("N/A", text: $data.suffixSymbol)
                        .textInputAutocapitalization(.characters)
                }
                env.theme.field.text(edit, "Decimal Point") {
                    TextField("N/A", text: $data.decimalPoint)
                }
                env.theme.field.text(edit, "Thousands Separator") {
                    TextField("N/A", text: $data.groupSeparator)
                }
                env.theme.field.text(edit, "Scale") {
                    TextField("Default is 0", value: $data.scale, format: .number)
                        .keyboardType(.decimalPad)
                }
            }
        }
    }
}

#Preview("\(CurrencyData.sampleData[0].symbol) (show)") {
    let env = EnvironmentManager.sampleData
    Form { CurrencyEditView(
        vm: ViewModel(env: env),
        data: .constant(CurrencyData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview("\(CurrencyData.sampleData[0].symbol) (edit)") {
    let env = EnvironmentManager.sampleData
    Form { CurrencyEditView(
        vm: ViewModel(env: env),
        data: .constant(CurrencyData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(EnvironmentManager.sampleData)
}

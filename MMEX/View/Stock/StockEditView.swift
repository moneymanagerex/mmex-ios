//
//  StockEditView.swift
//  MMEX
//
//  2024-10-03: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct StockEditView: View {
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @Binding var data: StockData
    @State var edit: Bool

    var account: AccountData? { vm.accountList.data.readyValue?[data.accountId] }
    var currency: CurrencyInfo? { account != nil ? vm.currencyList.info.readyValue?[account!.currencyId] : nil }
    var formatter: CurrencyFormatter? { currency?.formatter }

    var body: some View {
        Section {
            env.theme.field.text(edit, "Name") {
                TextField("Cannot be empty!", text: $data.name)
                    .textInputAutocapitalization(.words)
            } show: {
                env.theme.field.valueOrError("Cannot be empty!", text: data.name)
            }
            
            env.theme.field.text(edit, "Symbol") {
                TextField("Cannot be empty!", text: $data.symbol)
                    .textInputAutocapitalization(.characters)
            } show: {
                env.theme.field.valueOrError("Cannot be empty!", text: data.symbol)
            }

            if
                let accountOrder = vm.accountList.order.readyValue,
                let accountData  = vm.accountList.data.readyValue
            {
                env.theme.field.picker(edit, "Account") {
                    Picker("", selection: $data.accountId) {
                        if (data.accountId.isVoid) {
                            Text("Select Account").tag(DataId.void) // not set
                        }
                        ForEach(accountOrder, id: \.self) { id in
                            Text(accountData[id]?.name ?? "").tag(id)
                        }
                    }
                } show: {
                    env.theme.field.valueOrError("Cannot be empty!", text: account?.name)
                }
            }
        }
        
        Section {
            env.theme.field.text(edit, "Number of Shares") {
                TextField("Default is 0", value: $data.numShares, format: .number)
                    .keyboardType(.decimalPad)
            }
            
            env.theme.field.date(edit, "Purchase Date") {
                DatePicker("", selection: $data.purchaseDate.date, displayedComponents: [.date])
            } show: {
                env.theme.field.valueOrError("Should not be empty!", text: data.purchaseDate.string)
            }
            
            env.theme.field.text(edit, "Purchase Price") {
                TextField("Default is 0", value: $data.purchasePrice, format: .number)
                    .keyboardType(.decimalPad)
            }
            
            env.theme.field.text(edit, "Current Price") {
                TextField("Default is 0", value: $data.currentPrice, format: .number)
                    .keyboardType(.decimalPad)
            }
            
            env.theme.field.text(edit, "Purchase Value") {
                TextField("Default is 0", value: $data.purchaseValue, format: .number)
                    .keyboardType(.decimalPad)
            } show: {
                Text(data.purchaseValue.formatted(by: formatter))
            }
            
            env.theme.field.text(edit, "Commisison") {
                TextField("Default is 0", value: $data.commisison, format: .number)
                    .keyboardType(.decimalPad)
            } show: {
                Text(data.commisison.formatted(by: formatter))
            }
        }
        Section {
            env.theme.field.editor(edit, "Notes") {
                TextEditor(text: $data.notes)
                    .textInputAutocapitalization(.never)
            } show: {
                env.theme.field.valueOrHint("N/A", text: data.notes)
            }
        }
    }
}

#Preview("\(StockData.sampleData[0].name) (show)") {
    let env = EnvironmentManager.sampleData
    Form { StockEditView(
        vm: ViewModel(env: env),
        data: .constant(StockData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(env)
}

#Preview("\(StockData.sampleData[0].name) (edit)") {
    let env = EnvironmentManager.sampleData
    Form { StockEditView(
        vm: ViewModel(env: env),
        data: .constant(StockData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(env)
}

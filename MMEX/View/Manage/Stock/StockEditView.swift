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
            env.theme.field.view(edit, "Name", editView: {
                TextField("Cannot be empty!", text: $data.name)
                    .textInputAutocapitalization(.words)
            }, showView: {
                env.theme.field.valueOrError("Cannot be empty!", text: data.name)
            } )
            
            env.theme.field.view(edit, "Symbol", editView: {
                TextField("Cannot be empty!", text: $data.symbol)
                    .textInputAutocapitalization(.characters)
            }, showView: {
                env.theme.field.valueOrError("Cannot be empty!", text: data.symbol)
            } )

            if
                let accountOrder = vm.accountList.order.readyValue,
                let accountData  = vm.accountList.data.readyValue
            {
                env.theme.field.view(edit, false, "Account", editView: {
                    Picker("", selection: $data.accountId) {
                        if (data.accountId.isVoid) {
                            Text("(none)").tag(DataId.void)
                        }
                        ForEach(accountOrder, id: \.self) { id in
                            Text(accountData[id]?.name ?? "").tag(id)
                        }
                    }
                }, showView: {
                    env.theme.field.valueOrError("Cannot be empty!", text: account?.name)
                } )
            }
        }

        Section {
            env.theme.field.view(edit, true, "Number of Shares", editView: {
                TextField("Default is 0", value: $data.numShares.defaultZero, format: .number)
                    .keyboardType(.decimalPad)
            }, showView: {
                Text("\(data.numShares)")
            } )
            
            env.theme.field.view(edit, true, "Purchase Date", editView: {
                DatePicker("", selection: $data.purchaseDate.date, displayedComponents: [.date])
                    .labelsHidden()
            }, showView: {
                env.theme.field.valueOrError("Should not be empty!", text: data.purchaseDate.string)
            } )
            
            env.theme.field.view(edit, true, "Purchase Price", editView: {
                TextField("Default is 0", value: $data.purchasePrice.defaultZero, format: .number)
                    .keyboardType(.decimalPad)
            }, showView: {
                Text("\(data.purchasePrice)")
            } )
            
            env.theme.field.view(edit, true, "Current Price", editView: {
                TextField("Default is 0", value: $data.currentPrice.defaultZero, format: .number)
                    .keyboardType(.decimalPad)
            }, showView: {
                Text("\(data.currentPrice)")
            } )
            
            env.theme.field.view(edit, true, "Purchase Value", editView: {
                TextField("Default is 0", value: $data.purchaseValue.defaultZero, format: .number)
                    .keyboardType(.decimalPad)
            }, showView: {
                Text(data.purchaseValue.formatted(by: formatter))
            } )
            
            env.theme.field.view(edit, true, "Commisison", editView: {
                TextField("Default is 0", value: $data.commisison.defaultZero, format: .number)
                    .keyboardType(.decimalPad)
            }, showView: {
                Text(data.commisison.formatted(by: formatter))
            } )
        }

        Section {
            env.theme.field.view(edit, "Notes", editView: {
                TextEditor(text: $data.notes)
                    .textInputAutocapitalization(.never)
                    .frame(minHeight: 20)
            }, showView: {
                env.theme.field.valueOrHint("N/A", text: data.notes)
            } )
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

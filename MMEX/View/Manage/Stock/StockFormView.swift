//
//  StockFormView.swift
//  MMEX
//
//  2024-10-03: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct StockFormView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @Binding var data: StockData
    @State var edit: Bool

    var account: AccountData? { vm.accountList.data.readyValue?[data.accountId] }
    var currency: CurrencyInfo? { account != nil ? vm.currencyList.info.readyValue?[account!.currencyId] : nil }
    var formatter: CurrencyFormatter? { currency?.formatter }

    var body: some View {
        Section {
            pref.theme.field.view(edit, "Name", editView: {
                TextField("Shall not be empty!", text: $data.name)
                    .keyboardType(pref.theme.textPad)
                    .textInputAutocapitalization(.words)
            }, showView: {
                pref.theme.field.valueOrError("Shall not be empty!", text: data.name)
            } )
            
            pref.theme.field.view(edit, "Symbol", editView: {
                TextField("Shall not be empty!", text: $data.symbol)
                    .keyboardType(pref.theme.textPad)
                    .textInputAutocapitalization(.characters)
            }, showView: {
                pref.theme.field.valueOrError("Shall not be empty!", text: data.symbol)
            } )

            if
                let accountOrder = vm.accountList.order.readyValue,
                let accountData  = vm.accountList.data.readyValue
            {
                pref.theme.field.view(edit, false, "Account", editView: {
                    Picker("", selection: $data.accountId) {
                        if (data.accountId.isVoid) {
                            Text("(none)").tag(DataId.void)
                        }
                        ForEach(accountOrder, id: \.self) { id in
                            Text(accountData[id]?.name ?? "").tag(id)
                        }
                    }
                }, showView: {
                    pref.theme.field.valueOrError("Shall not be empty!", text: account?.name)
                } )
            }
        }

        Section {
            pref.theme.field.view(edit, true, "Number of Shares", editView: {
                TextField("Default is 0", value: $data.numShares.defaultZero, format: .number)
                    .keyboardType(pref.theme.decimalPad)
            }, showView: {
                Text("\(data.numShares)")
            } )
            
            pref.theme.field.view(edit, true, "Purchase Date", editView: {
                DatePicker("", selection: $data.purchaseDate.date, displayedComponents: [.date])
                    .labelsHidden()
            }, showView: {
                pref.theme.field.valueOrError("Should not be empty!", text: data.purchaseDate.string)
            } )
            
            pref.theme.field.view(edit, true, "Purchase Price", editView: {
                TextField("Default is 0", value: $data.purchasePrice.defaultZero, format: .number)
                    .keyboardType(pref.theme.decimalPad)
            }, showView: {
                Text("\(data.purchasePrice)")
            } )
            
            pref.theme.field.view(edit, true, "Current Price", editView: {
                TextField("Default is 0", value: $data.currentPrice.defaultZero, format: .number)
                    .keyboardType(pref.theme.decimalPad)
            }, showView: {
                Text("\(data.currentPrice)")
            } )
            
            pref.theme.field.view(edit, true, "Purchase Value", editView: {
                TextField("Default is 0", value: $data.purchaseValue.defaultZero, format: .number)
                    .keyboardType(pref.theme.decimalPad)
            }, showView: {
                Text(data.purchaseValue.formatted(by: formatter))
            } )
            
            pref.theme.field.view(edit, true, "Commisison", editView: {
                TextField("Default is 0", value: $data.commisison.defaultZero, format: .number)
                    .keyboardType(pref.theme.decimalPad)
            }, showView: {
                Text(data.commisison.formatted(by: formatter))
            } )
        }

        Section("Notes") {
            pref.theme.field.notes(edit, "", $data.notes)
                .keyboardType(pref.theme.textPad)
        }
    }
}

#Preview("\(StockData.sampleData[0].name) (show)") {
    let pref = Preference()
    let vm = ViewModel.sampleData
    Form { StockFormView(
        data: .constant(StockData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(pref)
    .environmentObject(vm)
}

#Preview("\(StockData.sampleData[0].name) (edit)") {
    let pref = Preference()
    let vm = ViewModel.sampleData
    Form { StockFormView(
        data: .constant(StockData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(pref)
    .environmentObject(vm)
}

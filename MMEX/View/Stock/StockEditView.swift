//
//  StockEditView.swift
//  MMEX
//
//  Created 2024-10-03 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct StockEditView: View {
    @EnvironmentObject var env: EnvironmentManager
    @Binding var allAccountName: [(DataId, String)] // sorted by name
    @Binding var stock: StockData
    @State var edit: Bool
    var onDelete: () -> Void = { }

    var account: AccountInfo? { env.accountCache[stock.accountId] }
    var currency: CurrencyInfo? { account != nil ? env.currencyCache[account!.currencyId] : nil }
    var formatter: CurrencyFormatter? { currency?.formatter }

    var body: some View {
        Form {
            Section {
                env.theme.field.text(edit, "Name") {
                    TextField("Cannot be empty!", text: $stock.name)
                        .textInputAutocapitalization(.words)
                } show: {
                    env.theme.field.valueOrError("Cannot be empty!", text: stock.name)
                }
                
                env.theme.field.text(edit, "Symbol") {
                    TextField("Cannot be empty!", text: $stock.symbol)
                        .textInputAutocapitalization(.characters)
                } show: {
                    env.theme.field.valueOrError("Cannot be empty!", text: stock.symbol)
                }
                
                env.theme.field.picker(edit, "Account") {
                    Picker("", selection: $stock.accountId) {
                        if (stock.accountId <= 0) {
                            Text("Select Account").tag(0 as DataId) // not set
                        }
                        ForEach(allAccountName, id: \.0) { id, name in
                            Text(name).tag(id)
                        }
                    }
                } show: {
                    env.theme.field.valueOrError("Cannot be empty!", text: account?.name)
                }
            }

            Section {
                env.theme.field.text(edit, "Number of Shares") {
                    TextField("Default is 0", value: $stock.numShares, format: .number)
                        .keyboardType(.decimalPad)
                }

                env.theme.field.date(edit, "Purchase Date") {
                    DatePicker("", selection: $stock.purchaseDate.date, displayedComponents: [.date])
                } show: {
                    env.theme.field.valueOrError("Should not be empty!", text: stock.purchaseDate.string)
                }
                
                env.theme.field.text(edit, "Purchase Price") {
                    TextField("Default is 0", value: $stock.purchasePrice, format: .number)
                        .keyboardType(.decimalPad)
                }

                env.theme.field.text(edit, "Current Price") {
                    TextField("Default is 0", value: $stock.currentPrice, format: .number)
                        .keyboardType(.decimalPad)
                }

                env.theme.field.text(edit, "Purchase Value") {
                    TextField("Default is 0", value: $stock.purchaseValue, format: .number)
                        .keyboardType(.decimalPad)
                } show: {
                    Text(stock.purchaseValue.formatted(by: formatter))
                }

                env.theme.field.text(edit, "Commisison") {
                    TextField("Default is 0", value: $stock.commisison, format: .number)
                        .keyboardType(.decimalPad)
                } show: {
                    Text(stock.commisison.formatted(by: formatter))
                }
            }
            Section {
                env.theme.field.editor(edit, "Notes") {
                    TextEditor(text: $stock.notes)
                        .textInputAutocapitalization(.never)
                } show: {
                    env.theme.field.valueOrHint("N/A", text: stock.notes)
                }
            }
            
            // TODO: delete account if not in use
            if true {
                Button("Delete Stock") {
                    onDelete()
                }
                .foregroundColor(.red)
            }
        }
        .textSelection(.enabled)
    }
}

#Preview("\(StockData.sampleData[0].name) (show)") {
    StockEditView(
        allAccountName: .constant(CurrencyData.sampleDataName),
        stock: .constant(StockData.sampleData[0]),
        edit: false
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview("\(StockData.sampleData[0].name) (edit)") {
    StockEditView(
        allAccountName: .constant(CurrencyData.sampleDataName),
        stock: .constant(StockData.sampleData[0]),
        edit: true
    )
    .environmentObject(EnvironmentManager.sampleData)
}

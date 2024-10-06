//
//  StockEditView.swift
//  MMEX
//
//  Created 2024-10-03 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct StockEditView: View {
    @EnvironmentObject var env: EnvironmentManager
    @Binding var allAccountName: [(Int64, String)] // sorted by name
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
                    TextField("Stock Name", text: $stock.name)
                        .textInputAutocapitalization(.words)
                }
                env.theme.field.text(edit, "Symbol") {
                    TextField("Stock Symbol", text: $stock.symbol)
                        .textInputAutocapitalization(.characters)
                }
                env.theme.field.picker(edit, "Account") {
                    Picker("", selection: $stock.accountId) {
                        if (stock.accountId == 0) {
                            Text("Select Account").tag(0 as Int64) // not set
                        }
                        ForEach(allAccountName, id: \.0) { id, name in
                            Text(name).tag(id)
                        }
                    }
                } show: {
                    Text(account?.name ?? "Unknown account!")
                }
            }

            Section {
                env.theme.field.text(edit, "Number of Shares") {
                    TextField("Number of Shares", value: $stock.numShares, format: .number)
                        .keyboardType(.decimalPad)
                }
                env.theme.field.date(edit, "Purchase Date") {
                    DatePicker("", selection: $stock.purchaseDate.date, displayedComponents: [.date]
                    )
                } show: {
                    Text(stock.purchaseDate.string)
                }
                env.theme.field.text(edit, "Purchase Price") {
                    TextField("Purchase Price", value: $stock.purchasePrice, format: .number)
                        .keyboardType(.decimalPad)
                }
                env.theme.field.text(edit, "Current Price") {
                    TextField("Current Price", value: $stock.currentPrice, format: .number)
                        .keyboardType(.decimalPad)
                }
                env.theme.field.text(edit, "Value") {
                    TextField("Value", value: $stock.value, format: .number)
                        .keyboardType(.decimalPad)
                } show: {
                    Text(stock.value.formatted(by: formatter))
                }
                env.theme.field.text(edit, "Commisison") {
                    TextField("Commisison", value: $stock.commisison, format: .number)
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
                    Text(stock.notes)
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

#Preview {
    StockEditView(
        allAccountName: .constant(CurrencyData.sampleDataName),
        stock: .constant(StockData.sampleData[0]),
        edit: false
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview {
    StockEditView(
        allAccountName: .constant(CurrencyData.sampleDataName),
        stock: .constant(StockData.sampleData[0]),
        edit: true
    )
    .environmentObject(EnvironmentManager.sampleData)
}

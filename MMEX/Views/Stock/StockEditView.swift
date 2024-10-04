//
//  StockEditView.swift
//  MMEX
//
//  Created 2024-10-03 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct StockEditView: View {
    @Binding var allAccountName: [(Int64, String)] // sorted by name
    @Binding var stock: StockData

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Stock Name")) {
                    TextField("Enter stock name", text: $stock.name)
                }

                Section(header: Text("Account")) {
                    Picker("Account", selection: $stock.accountId) {
                        if (stock.accountId == 0) {
                            Text("Account").tag(0 as Int64) // not set
                        }
                        ForEach(allAccountName, id: \.0) { id, name in
                            Text(name).tag(id) // Use acccount name to display and tag by id
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // Adjust the style of the picker as needed
                }

                Section(header: Text("Number of Shares")) {
                    TextField("Enter number of shares", value: $stock.numShares, format: .number)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Purchase Date")) {
                    TextField("Enter purchase date", text: $stock.purchaseDate)
                }

                Section(header: Text("Purchase Price")) {
                    TextField("Enter purchase price", value: $stock.purchasePrice, format: .number)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Value")) {
                    TextField("Enter value", value: $stock.value, format: .number)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Commisison")) {
                    TextField("Enter commission", value: $stock.commisison, format: .number)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Notes")) {
                    TextField("Notes", text: $stock.notes)
                }
            }
        }
    }
}

#Preview {
    StockEditView(
        allAccountName: .constant(CurrencyData.sampleDataName),
        stock: .constant(StockData.sampleData[0])
    )
}

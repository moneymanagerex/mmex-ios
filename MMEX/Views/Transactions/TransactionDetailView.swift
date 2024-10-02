//
//  TransactionDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var viewModel: InfotableViewModel
    @Binding var accountId: [Int64]  // sorted by name
    @Binding var categories: [CategoryData]
    @Binding var payees: [PayeeData]
    @Binding var txn: TransactionData

    @State private var editingTxn = TransactionData()
    @State private var isPresentingEditView = false
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    
    @State private var account: AccountData?
    @State private var toAccount: AccountData?
    @State private var isExporting = false

    var body: some View {
        List {
            Section(header: Text("Transaction Type")) {
                Text("\(txn.transCode.name)")
            }

            Section(header: Text("Transaction Status")) {
                Text("\(txn.status.fullName)")
            }

            Section(header: Text("Transaction Amount")) {
                Text(txn.transAmount.formatted(
                    by: dataManager.currencyCache[account?.currencyId ?? 0]?.formatter
                ))
            }

            Section(header: Text("Transaction Date")) {
                Text(txn.transDate) // Display the transaction date
            }

            Section(header: Text("Account Name")) {
                if let account = dataManager.accountCache[txn.accountId] {
                    Text("\(account.name)")
                } else {
                    Text("n/a")
                }
            }

            if txn.transCode == .transfer {
                Section(header: Text("To Account")) {
                    if let toAccount = dataManager.accountCache[txn.toAccountId] {
                        Text("\(toAccount.name)")
                    } else {
                        Text("n/a")
                    }
                }
            } else {
                Section(header: Text("Payee")) {
                    // Text(getPayeeName(txn.payeeID)) // Retrieve payee name
                    Text(getPayeeName(for:txn.payeeId))
                }
            }

            if !txn.splits.isEmpty {
                Section(header: Text("Splits")) {
                    // header
                    HStack {
                        Text("Category")
                            .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                        Text("Amount")
                            .frame(width: 80, alignment: .center) // Centered with fixed width
                        Text("Notes")
                            .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                    }
                    // rows
                    ForEach(txn.splits) { split in
                        HStack {
                            Text(getCategoryName(for: split.categId))
                                .frame(maxWidth: .infinity, alignment: .leading) // Align to the left

                            Text(split.amount.formatted(
                                by: dataManager.currencyCache[account?.currencyId ?? 0]?.formatter
                            ))
                            .frame(width: 80, alignment: .center) // Centered with fixed width

                            Text(split.notes)
                                .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                        }
                    }
                }
            } else {
                Section(header: Text("Category")) {
                    Text(getCategoryName(for:txn.categId))
                }
            }

            Section(header: Text("Notes")) {
                Text(txn.notes)
            }
            // Section for actions like delete
            Section {
                Button("Delete Transaction") {
                    if viewModel.deleteTransaction(txn) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .foregroundColor(.red)
            }
        }
        .textSelection(.enabled)
        .toolbar {
            Button("Edit") {
                isPresentingEditView = true
                editingTxn = txn
            }
            // Export button for pasteboard and external storage
            Menu {
                Button("Copy to Clipboard") {
                    txn.copyToPasteboard()
                }
                Button("Export as JSON File") {
                    isExporting = true
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                TransactionEditView(
                    accountId: $accountId,
                    categories: $categories,
                    payees: $payees,
                    txn: $editingTxn
                )
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isPresentingEditView = false
                                txn = editingTxn
                                if (viewModel.updateTransaction(&txn) == false) {
                                    // TODO
                                }
                            }
                            .disabled(!editingTxn.isValid)
                        }
                    }
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: ExportableEntityDocument(entity: txn),
            contentType: .json,
            defaultFilename: String(format: "%d_Transaction", txn.id)
        ) { result in
            switch result {
            case .success(let url):
                print("File saved to: \(url)")
            case .failure(let error):
                print("Error exporting file: \(error)")
            }
        }
    }
    
    func getCategoryName(for categoryID: Int64) -> String {
        return categories.first {$0.id == categoryID}?.name ?? "Unknown"
    }

    func getPayeeName(for payeeID: Int64) -> String {
        return payees.first {$0.id == payeeID}?.name ?? "Unknown"
    }
}

#Preview {
    TransactionDetailView(
        viewModel: InfotableViewModel(dataManager: DataManager()),
        accountId: .constant(AccountData.sampleDataIds),
        categories: .constant(CategoryData.sampleData),
        payees: .constant(PayeeData.sampleData),
        txn: .constant(TransactionData.sampleData[0])
    )
    .environmentObject(DataManager.sampleDataManager)
}

#Preview {
    TransactionDetailView(
        viewModel: InfotableViewModel(dataManager: DataManager()),
        accountId: .constant(AccountData.sampleDataIds),
        categories: .constant(CategoryData.sampleData),
        payees: .constant(PayeeData.sampleData),
        txn: .constant(TransactionData.sampleData[2])
    )
    .environmentObject(DataManager.sampleDataManager)
}

#Preview {
    TransactionDetailView(
        viewModel: InfotableViewModel(dataManager: DataManager()),
        accountId: .constant(AccountData.sampleDataIds),
        categories: .constant(CategoryData.sampleData),
        payees: .constant(PayeeData.sampleData),
        txn: .constant(TransactionData.sampleData[3])
    )
    .environmentObject(DataManager.sampleDataManager)
}

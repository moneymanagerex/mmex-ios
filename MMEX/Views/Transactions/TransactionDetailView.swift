//
//  TransactionDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionDetailView: View {
    @State var txn: TransactionData
    @EnvironmentObject var dataManager: DataManager

    @State private var editingTxn = TransactionData()
    @State private var isPresentingEditView = false
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    
    @Binding var payees: [PayeeData]
    @Binding var categories: [CategoryData]
    @Binding var accounts: [AccountData]
    
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
                if let currencyId = account?.currencyId,
                   let currencyFormat = dataManager.currencyFormat[currencyId]
                {
                    Text(currencyFormat.format(amount: txn.transAmount))
                } else {
                    Text("\(txn.transAmount)")
                }
            }

            Section(header: Text("Transaction Date")) {
                Text(txn.transDate) // Display the transaction date
            }

            Section(header: Text("Account Name")) {
                if let account = account {
                    Text("\(account.name)")
                } else {
                    Text("n/a")
                }
            }

            if txn.transCode == .transfer {
                Section(header: Text("To Account")) {
                    if let toAccount = toAccount {
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
                        Spacer()
                        Text("Amount")
                        Spacer()
                        Text("Notes")
                    }
                    // rows
                    ForEach(txn.splits) { split in
                        HStack {
                            Text(getCategoryName(for: split.categId))
                            Spacer()

                            if let currencyId = account?.currencyId,
                               let currencyFormat = dataManager.currencyFormat[currencyId]
                            {
                                Text(currencyFormat.format(amount: split.amount))
                            } else {
                                Text("\(split.amount, specifier: "%.2f")")
                            }
                            Spacer()

                            Text(split.notes)
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
                    deleteTxn()
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
                TransactionEditView(txn: $editingTxn, payees: $payees, categories: $categories, accounts: $accounts)
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
                                saveChanges()
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
        .onAppear(){
            loadAccount()
            if txn.transCode == .transfer { loadToAccount() }
        }
    }
    
    func loadAccount() {
        account = accounts.first { $0.id == txn.accountId}
    }
    func loadToAccount() {
        toAccount = accounts.first { $0.id == txn.toAccountId}
    }
    func getCategoryName(for categoryID: Int64) -> String {
        return categories.first {$0.id == categoryID}?.name ?? "Unknown"
    }
    func getPayeeName(for payeeID: Int64) -> String {
        return payees.first {$0.id == payeeID}?.name ?? "Unknown"
    }

    func saveChanges() {
        let repository = dataManager.transactionRepository // pass URL here
        if repository?.updateWithSplits(&txn) == true {
            // TODO
        } else {
            // TODO update failure
        }
    }
    
    func deleteTxn(){
        let repository = dataManager.transactionRepository // pass URL here
        if repository?.delete(txn) == true {
            // Dismiss the TransactionDetailView and go back to the previous view
            presentationMode.wrappedValue.dismiss()
        } else {
            // TODO
            // handle deletion failure
        }
    }
}

#Preview {
    TransactionDetailView(
        txn: TransactionData.sampleData[0],
        payees: .constant(PayeeData.sampleData),
        categories: .constant(CategoryData.sampleData),
        accounts: .constant(AccountData.sampleData)
    )
    .environmentObject(DataManager())
}

#Preview {
    TransactionDetailView(
        txn: TransactionData.sampleData[2],
        payees: .constant(PayeeData.sampleData),
        categories: .constant(CategoryData.sampleData),
        accounts: .constant(AccountData.sampleData)
    )
    .environmentObject(DataManager())
}

#Preview {
    TransactionDetailView(
        txn: TransactionData.sampleData[3],
        payees: .constant(PayeeData.sampleData),
        categories: .constant(CategoryData.sampleData),
        accounts: .constant(AccountData.sampleData)
    )
    .environmentObject(DataManager())
}

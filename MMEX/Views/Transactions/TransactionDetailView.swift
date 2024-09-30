//
//  TransactionDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    @State var txn: TransactionData

    @State private var editingTxn = TransactionData()
    @State private var isPresentingEditView = false
    @Environment(\.presentationMode) var presentationMode // To dismiss the view

    @Binding var accountId: [Int64]
    @Binding var categories: [CategoryData]
    @Binding var payees: [PayeeData]
    
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
                    by: dataManager.currencyFormatter[account?.currencyId ?? 0]
                ))
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
                    Text("\(txn.payeeId)")
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
                TransactionEditView(
                    txn: $editingTxn,
                    accountId: $accountId,
                    categories: $categories,
                    payees: $payees
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
        account = dataManager.accountData[txn.accountId]
    }
    func loadToAccount() {
        toAccount = dataManager.accountData[txn.toAccountId]
    }

    func saveChanges() {
        let repository = dataManager.transactionRepository // pass URL here
        if repository?.update(txn) == true {
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
        accountId: .constant(AccountData.sampleData.map { account in
            account.id
        } ),
        categories: .constant(CategoryData.sampleData),
        payees: .constant(PayeeData.sampleData)
    )
    .environmentObject(DataManager())
}

#Preview {
    TransactionDetailView(
        txn: TransactionData.sampleData[2],
        accountId: .constant(AccountData.sampleData.map { account in
            account.id
        } ),
        categories: .constant(CategoryData.sampleData),
        payees: .constant(PayeeData.sampleData)
    )
    .environmentObject(DataManager())
}

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
                    by: dataManager.currencyCache[account?.currencyId ?? 0]?.formatter
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

                            Text(split.amount.formatted(
                                by: dataManager.currencyCache[account?.currencyId ?? 0]?.formatter
                            ))

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
        txn: TransactionData.sampleData[0],
        accountId: .constant(AccountData.sampleDataIds),
        categories: .constant(CategoryData.sampleData),
        payees: .constant(PayeeData.sampleData)
    )
    .environmentObject(DataManager())
}

#Preview {
    TransactionDetailView(
        viewModel: InfotableViewModel(dataManager: DataManager()),
        txn: TransactionData.sampleData[2],
        accountId: .constant(AccountData.sampleDataIds),
        categories: .constant(CategoryData.sampleData),
        payees: .constant(PayeeData.sampleData)
    )
    .environmentObject(DataManager())
}

#Preview {
    TransactionDetailView(
        viewModel: InfotableViewModel(dataManager: DataManager()),
        txn: TransactionData.sampleData[3],
        accountId: .constant(AccountData.sampleDataIds),
        categories: .constant(CategoryData.sampleData),
        payees: .constant(PayeeData.sampleData)
    )
    .environmentObject(DataManager())
}

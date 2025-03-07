//
//  TransactionDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionDetailView: View {
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    @EnvironmentObject var vm: ViewModel
    @Binding var txn: TransactionData

    @State private var editingTxn = TransactionData()
    @State private var focus = false

    @State private var editSheetIsPresented = false
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
                    by: vm.currencyList.info.readyValue?[
                        vm.accountList.data.readyValue?[txn.accountId]?.currencyId ?? .void
                    ]?.formatter
                ))
            }

            Section(header: Text("Transaction Date")) {
                Text(txn.transDate.string)
            }

            Section(header: Text("Account Name")) {
                Text(vm.accountList.data.readyValue?[txn.accountId]?.name ?? "(unknown)")
            }

            if txn.transCode == .transfer {
                Section(header: Text("To Account")) {
                    Text(vm.accountList.data.readyValue?[txn.toAccountId]?.name ?? "(unknown)")
                }
            } else {
                Section(header: Text("Payee")) {
                    Text(vm.payeeList.data.readyValue?[txn.payeeId]?.name ?? "(unknown)")
                }
            }

            if txn.splits.isEmpty {
                Section(header: Text("Category")) {
                    Text(vm.categoryList.evalPath.readyValue?[txn.categId] ?? "(unknown)")
                }
            } else {
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
                            Text(vm.categoryList.evalPath.readyValue?[split.categId] ?? "(unknown)")
                                .frame(maxWidth: .infinity, alignment: .leading) // Align to the left

                            Text(split.amount.formatted(
                                by: vm.currencyList.info.readyValue?[
                                    vm.accountList.data.readyValue?[txn.accountId]?.currencyId ?? .void
                                ]?.formatter
                            ))
                            .frame(width: 80, alignment: .center) // Centered with fixed width

                            Text(split.notes)
                                .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                        }
                    }
                }
            }

            Section(header: Text("Notes")) {
                Text(txn.notes)
            }

            Section {
                Button("Delete Transaction") {
                    if vm.deleteTransaction(txn) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .foregroundColor(.red)
            }
        }
        .textSelection(.enabled)

        .toolbar {
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
                    .font(.footnote)
            }
            Button {
                editSheetIsPresented = true
                editingTxn = txn
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.footnote)
            }
        }

        .sheet(isPresented: $editSheetIsPresented) {
            NavigationView {
                TransactionEditView(
                    isPresented: $editSheetIsPresented,
                    txn: $txn,
                    editingTxn: $editingTxn
                )
            }
        }

        .fileExporter(
            isPresented: $isExporting,
            document: ExportableEntityDocument(entity: txn),
            contentType: .json,
            defaultFilename: String(format: "%d_Transaction", txn.id.value)
        ) { result in
            switch result {
            case .success(let url):
                log.info("File saved to: \(url)")
            case .failure(let error):
                log.error("Error exporting file: \(error)")
            }
        }
    }
}

/*
#Preview("txn #0") {
    let pref = Preference()
    let vm = ViewModel.sampleData
    TransactionDetailView(
        txn: .constant(TransactionData.sampleData[0])
    )
    .environmentObject(pref)
    .environmentObject(vm)
}

#Preview("txn #2") {
    let pref = Preference()
    let vm = ViewModel.sampleData
    TransactionDetailView(
        txn: .constant(TransactionData.sampleData[2])
    )
    .environmentObject(pref)
    .environmentObject(vm)
}

#Preview("txn #3") {
    let pref = Preference()
    let vm = ViewModel.sampleData
    TransactionDetailView(
        txn: .constant(TransactionData.sampleData[3])
    )
    .environmentObject(pref)
    .environmentObject(vm)
}
*/

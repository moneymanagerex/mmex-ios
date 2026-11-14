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
    @EnvironmentObject var journalViewModel: JournalViewModel
    @Binding var journal: JournalData

    @State private var focus = false

    @State private var editSheetIsPresented = false
    @State private var editHasChanges = false
    @State private var isExporting = false
    @State private var showingCopyOptions = false
    @State private var copyDraft: JournalData?
    @State private var copySelectedTab = 0
    @State private var copyHasChanges = false

    var body: some View {
        List {
            Section(header: Text("Transaction Type")) {
                Text("\(journal.transCode.name)")
            }

            Section(header: Text("Transaction Status")) {
                Text("\(journal.status.fullName)")
            }

            Section(header: Text("Transaction Amount")) {
                Text(journal.transAmount.formatted(
                    by: vm.currencyList.info.readyValue?[
                        vm.accountList.data.readyValue?[journal.accountId]?.currencyId ?? .void
                    ]?.formatter
                ))
            }

            Section(header: Text("Transaction Date")) {
                Text(journal.transDate.string)
            }

            Section(header: Text("Account Name")) {
                Text(vm.accountList.data.readyValue?[journal.accountId]?.name ?? "(unknown)")
            }

            if journal.transCode == .transfer {
                Section(header: Text("To Account")) {
                    Text(vm.accountList.data.readyValue?[journal.toAccountId]?.name ?? "(unknown)")
                }
            } else {
                Section(header: Text("Payee")) {
                    Text(vm.payeeList.data.readyValue?[journal.payeeId]?.name ?? "(unknown)")
                }
            }

            if journal.type == .scheduled {
                Section(header: Text("Schedule")) {
                    HStack {
                        Text("Next Due Date")
                        Spacer()
                        Text(journal.dueDate.string)
                    }
                    HStack {
                        Text("Repeat")
                        Spacer()
                        Text(journal.repeatAuto.name)
                    }
                    if journal.repeatAuto != .none {
                        HStack {
                            Text("Frequency")
                            Spacer()
                            Text(journal.repeatType.name)
                        }
                        HStack {
                            Text("Occurrences")
                            Spacer()
                            Text(journal.repeatNum == -1 ? "Infinite" : "\(journal.repeatNum)")
                        }
                    }
                }
            }

            if journal.splits.isEmpty {
                Section(header: Text("Category")) {
                    Text(vm.categoryList.evalPath.readyValue?[journal.categId] ?? "(unknown)")
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
                    ForEach(journal.splits) { split in
                        HStack {
                            Text(vm.categoryList.evalPath.readyValue?[split.categId] ?? "(unknown)")
                                .frame(maxWidth: .infinity, alignment: .leading) // Align to the left

                            Text(split.amount.formatted(
                                by: vm.currencyList.info.readyValue?[
                                    vm.accountList.data.readyValue?[journal.accountId]?.currencyId ?? .void
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
                Text(journal.notes)
            }

            Section {
                Button("Delete Journal") {
                    if journalViewModel.delete(journal, from: vm.db) {
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
                    journal.copyToPasteboard()
                }
                Button("Export as JSON File") {
                    isExporting = true
                }
                Button("Create Similar Transaction") {
                    showingCopyOptions = true
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.footnote)
            }
            .accessibilityLabel("Transaction actions")
            Button {
                editSheetIsPresented = true
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.footnote)
            }
            .accessibilityLabel("Edit transaction")
        }

        .sheet(isPresented: $editSheetIsPresented) {
            NavigationView {
                TransactionEditView(
                    isPresented: $editSheetIsPresented,
                    journal: $journal,
                    hasChanges: $editHasChanges
                )
            }
            .interactiveDismissDisabled(editHasChanges)
            .onAppear { editHasChanges = false }
        }
        .confirmationDialog("Copy the amount too?", isPresented: $showingCopyOptions) {
            Button("Copy with Amount") { copyDraft = similarTransaction(includeAmount: true) }
            Button("Copy without Amount") { copyDraft = similarTransaction(includeAmount: false) }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(item: $copyDraft) { draft in
            NavigationStack {
                EnterView(selectedTab: $copySelectedTab, hasChanges: $copyHasChanges, newJournal: draft)
                    .navigationTitle("New Transaction")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .interactiveDismissDisabled(copyHasChanges)
            .onAppear { copyHasChanges = false }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: ExportableEntityDocument(entity: journal),
            contentType: .json,
            defaultFilename: String(format: "%d_Transaction", journal.id.value)
        ) { result in
            switch result {
            case .success(let url):
                log.info("File saved to: \(url)")
            case .failure(let error):
                log.error("Error exporting file: \(error)")
            }
        }

    }

    private func similarTransaction(includeAmount: Bool) -> JournalData {
        var draft = JournalData.newTransaction()
        draft.accountId = journal.accountId
        draft.toAccountId = journal.toAccountId
        draft.payeeId = journal.payeeId
        draft.transCode = journal.transCode
        draft.categId = journal.categId
        if includeAmount {
            draft.transAmount = journal.transAmount
            draft.toTransAmount = journal.toTransAmount
            draft.splits = journal.splits.map {
                JournalSplitData(categId: $0.categId, amount: $0.amount, notes: $0.notes)
            }
        }
        return draft
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

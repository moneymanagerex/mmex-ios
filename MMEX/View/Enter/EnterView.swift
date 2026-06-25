//
//  EnterView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct EnterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @EnvironmentObject var context: AppContext
    @Binding var selectedTab: Int

    @State private var focus = false
    @State var newJournal: JournalData = .newTransaction()
    @State private var journalType: JournalType = .transaction
    
    var body: some View {
        EnterFormView(
            focus: $focus,
            journal: $newJournal
        )
        .padding(.horizontal, 0)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                    selectedTab = Preference.selectedTab
                    resetJournal()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    _ = vm.saveJournal(&newJournal)
                    dismiss()
                    selectedTab = Preference.selectedTab
                    resetJournal()
                }
                .disabled(!newJournal.isValid)
            }
            ToolbarItem(placement: .confirmationAction) {
                KeyboardFocus(focus: $focus)
            }
        }
        .task {
            await load()
        }
        .onChange(of: journalType) { _, newType in
            if newType == .transaction {
                newJournal = .newTransaction()
            } else {
                newJournal = .newScheduled()
            }
        }
    }

    private func load() async {
        log.trace("DEBUG: EnterView.load(main=\(Thread.isMainThread))")
        await vm.loadEnterList(pref)

        if newJournal.accountId.isVoid {
            if !context.selectedAccountId.isVoid {
                newJournal.accountId = context.selectedAccountId
            } else if let defaultAccountId = vm.infotableList.defaultAccountId.readyValue {
                newJournal.accountId = defaultAccountId
            } else if let accountOrder = vm.accountList.order.readyValue, accountOrder.count == 1 {
                newJournal.accountId = accountOrder[0]
            }
        }

        if newJournal.categId.isVoid {
            if let categoryOrder = vm.categoryList.order.readyValue, categoryOrder.count == 1 {
                newJournal.categId = categoryOrder[0]
            }
        }

        if newJournal.payeeId.isVoid {
            if let payeeOrder = vm.payeeList.order.readyValue, payeeOrder.count == 1 {
                newJournal.payeeId = payeeOrder[0]
            } else if pref.enter.reuseLastPayee == .boolTrue, !newJournal.accountId.isVoid {
                loadLatestTxn(for: newJournal.accountId)
            }
        }

        if newJournal.id.isVoid {
            newJournal.status = pref.enter.defaultStatus
        }
    }
    
    private func resetJournal() {
        newJournal = .newTransaction()
        journalType = .transaction
    }

    func loadLatestTxn(for accountId: DataId) {
        let repository = TransactionRepository(vm.db)
        if let latestTxn = repository?.latest(accountID: accountId).toOptional() ?? repository?.latest().toOptional() {
            // Update UI on the main thread
            DispatchQueue.main.async {
                if newJournal.payeeId.isVoid {
                    newJournal.payeeId = latestTxn.payeeId
                    // txn.categId = latestTxn.categId
                }
            }
        }
    }
}

#Preview {
    MMEXPreview.tab("Enter") { pref, vm in
        EnterView(
            selectedTab: .constant(0)
        )
    }
}

extension MMEXPreview {
    // TODO: add focus

    @ViewBuilder
    static func enter(
        _ data: TransactionData
    ) -> some View {
        MMEXPreview.tab("Enter") { pref, vm in
            EnterView(
                selectedTab: .constant(0),
                newJournal: JournalData(data)
            )
        }
    }
}

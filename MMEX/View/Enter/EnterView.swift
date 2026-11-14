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
    @EnvironmentObject var journalViewModel: JournalViewModel
    @EnvironmentObject var context: AppContext
    @Binding var selectedTab: Int
    @Binding var hasChanges: Bool

    @State private var focus = false
    @State var newJournal: JournalData = .newTransaction()
    @State private var initialJournal: JournalData?
    @State private var showingDiscardConfirmation = false
    @State private var showingSaveError = false
    @State private var justSaved = false

    init(selectedTab: Binding<Int>, hasChanges: Binding<Bool> = .constant(false), newJournal: JournalData = .newTransaction()) {
        self._selectedTab = selectedTab
        self._hasChanges = hasChanges
        self._newJournal = State(initialValue: newJournal)
    }
    
    var body: some View {
        EnterFormView(
            focus: $focus,
            journal: $newJournal
        )
        .padding(.horizontal, 0)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    if let initialJournal, initialJournal != newJournal {
                        showingDiscardConfirmation = true
                    } else {
                        discard()
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    if (journalViewModel.save(&newJournal, to: vm.db)) {
                        dismiss()
                        selectedTab = Preference.selectedTab
                        resetJournal()
                    } else {
                        log.warning("Failed to save journal")
                        showingSaveError = true
                    }
                }
                .disabled(!newJournal.isValid)
            }
            ToolbarItem(placement: .confirmationAction) {
                KeyboardFocus(focus: $focus)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 4) {
                if justSaved {
                    Text("Saved. Ready for another transaction.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Button("Save and Add Another") {
                    let account = newJournal.accountId
                    let transCode = newJournal.transCode
                    if journalViewModel.save(&newJournal, to: vm.db) {
                        resetJournal()
                        newJournal.accountId = account
                        newJournal.transCode = transCode
                        newJournal.status = pref.enter.defaultStatus
                        initialJournal = newJournal
                        justSaved = true
                    } else {
                        log.warning("Failed to save journal")
                        showingSaveError = true
                    }
                }
                .buttonStyle(.bordered)
                .disabled(!newJournal.isValid)
            }
            .padding(.bottom, 4)
        }
        .alert("Discard changes?", isPresented: $showingDiscardConfirmation) {
            Button("Discard Changes", role: .destructive) { discard() }
            Button("Keep Editing", role: .cancel) { }
        }
        .alert("Could not save transaction", isPresented: $showingSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your changes are still here. Please try again.")
        }
        .onChange(of: newJournal) { _, journal in
            if journal != initialJournal { justSaved = false }
            hasChanges = initialJournal != nil && journal != initialJournal
        }
        .interactiveDismissDisabled(initialJournal != nil && initialJournal != newJournal)
        .task {
            await load()
            initialJournal = newJournal
            hasChanges = false
        }
    }

    @MainActor
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
    }

    private func discard() {
        dismiss()
        selectedTab = Preference.selectedTab
        resetJournal()
    }

    @MainActor
    func loadLatestTxn(for accountId: DataId) {
        let repository = TransactionRepository(vm.db)
        if let latestTxn = repository?.latest(accountID: accountId).toOptional() ?? repository?.latest().toOptional() {
            if newJournal.payeeId.isVoid {
                newJournal.payeeId = latestTxn.payeeId
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

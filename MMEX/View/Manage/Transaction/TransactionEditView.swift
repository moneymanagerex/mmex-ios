//
//  TransactionEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionEditView: View {
    @EnvironmentObject var vm: ViewModel
    @EnvironmentObject var journalViewModel: JournalViewModel
    @Binding var isPresented: Bool
    @Binding var journal: JournalData
    @Binding var hasChanges: Bool

    @State private var editedJournal: JournalData  // local copy

    @State private var focus = false
    @State private var showingDiscardConfirmation = false
    @State private var showingSaveError = false

    init(isPresented: Binding<Bool>, journal: Binding<JournalData>, hasChanges: Binding<Bool>) {
        self._isPresented = isPresented
        self._journal = journal
        self._hasChanges = hasChanges
        self._editedJournal = State(initialValue: journal.wrappedValue)
    }

    var body: some View {
        EnterFormView(
            focus: $focus,
            journal: $editedJournal  // bind local copy
        )

        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    if editedJournal != journal {
                        showingDiscardConfirmation = true
                    } else {
                        isPresented = false
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    if journalViewModel.save(&editedJournal, to: vm.db) {
                        journal = editedJournal
                        isPresented = false
                    } else {
                        log.warning("Failed to save journal")
                        showingSaveError = true
                    }
                }
                .disabled(!editedJournal.isValid)
            }
            ToolbarItem(placement: .confirmationAction) {
                KeyboardFocus(focus: $focus)
            }
        }
        .alert("Discard changes?", isPresented: $showingDiscardConfirmation) {
            Button("Discard Changes", role: .destructive) { isPresented = false }
            Button("Keep Editing", role: .cancel) { }
        }
        .alert("Could not save transaction", isPresented: $showingSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your changes are still here. Please try again.")
        }
        .interactiveDismissDisabled(editedJournal != journal)
        .onChange(of: editedJournal) { _, value in
            hasChanges = value != journal
        }
    }
}

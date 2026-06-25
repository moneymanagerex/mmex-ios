//
//  TransactionEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionEditView: View {
    @EnvironmentObject var vm: ViewModel
    @Binding var isPresented: Bool
    @Binding var journal: JournalData

    @State private var editedJournal: JournalData  // local copy

    @State private var focus = false

    init(isPresented: Binding<Bool>, journal: Binding<JournalData>) {
        self._isPresented = isPresented
        self._journal = journal
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
                    isPresented = false
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    journal = editedJournal
                    _ = vm.saveJournal(&journal)
                    isPresented = false
                }
                .disabled(!editedJournal.isValid)
            }
            ToolbarItem(placement: .confirmationAction) {
                KeyboardFocus(focus: $focus)
            }
        }
    }
}

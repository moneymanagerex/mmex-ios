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

    @State private var focus = false

    var body: some View {
        EnterFormView(
            focus: $focus,
            journal: $journal
        )

        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isPresented = false
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    print("🟢 Done button tapped")
                    print("  - Before save: journal.id = \(journal.id), amount = \(journal.transAmount)")
                    isPresented = false
                    if (vm.saveJournal(&journal) == false) {
                        // TODO
                    }
                }
                .disabled(!journal.isValid)
            }
            ToolbarItem(placement: .confirmationAction) {
                KeyboardFocus(focus: $focus)
            }
        }
    }
}

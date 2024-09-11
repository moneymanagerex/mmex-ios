//
//  AccountAddView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import SwiftUI

struct AccountAddView: View {
    @Binding var newAccount: Account
    @Binding var isPresentingAccountAddView: Bool
    
    var onSave: (inout Account) -> Void
    
    var body: some View {
        NavigationStack {
            AccountEditView(account: $newAccount)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            isPresentingAccountAddView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            isPresentingAccountAddView = false
                            onSave(&newAccount)
                        }
                    }
                }
        }
    }
}

#Preview {
    AccountAddView(newAccount: .constant(Account.empty), isPresentingAccountAddView: .constant(true)) { newAccount in
        // Handle saving in preview
        print("New account: \(newAccount.name)")
    }
}

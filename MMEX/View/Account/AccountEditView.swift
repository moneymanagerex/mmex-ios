//
//  AccountEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//  Edited 2024-10-05 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AccountEditView: View {
    @EnvironmentObject var env: EnvironmentManager
    @Binding var allCurrencyName: [(Int64, String)] // sorted by name
    @Binding var account: AccountData
    @State var edit: Bool
    var onDelete: () -> Void = { }

    var currency: CurrencyInfo? { env.currencyCache[account.currencyId] }
    var formatter: CurrencyFormatter? { currency?.formatter }

    var body: some View {
        Form {
            Section {
                env.theme.field.text(edit, "Name") {
                    TextField("Account Name", text: $account.name)
                        .textInputAutocapitalization(.words)
                }
                env.theme.field.picker(edit, "Type") {
                    Picker("", selection: $account.type) {
                        ForEach(AccountType.allCases) { type in
                            Text(type.name).tag(type)
                        }
                    }
                } selected: {
                    Text(account.type.name)
                }
                env.theme.field.picker(edit, "Currency") {
                    Picker("", selection: $account.currencyId) {
                        if (account.currencyId == 0) {
                            Text("Select Currency").tag(0 as Int64) // not set
                        }
                        ForEach(allCurrencyName, id: \.0) { id, name in
                            Text(name).tag(id) // Use currency.name to display and tag by id
                        }
                    }
                } selected: {
                    Text(currency?.name ?? "Unknown currency!")
                }

                env.theme.field.toggle(edit, "Status") {
                    Toggle(isOn: $account.status.isOpen) {
                        Text(account.status.rawValue)
                    }
                } selected: {
                    Text(account.status.rawValue)
                }
                env.theme.field.toggle(edit, "Favorite") {
                    Toggle(isOn: $account.favoriteAcct.asBool) {
                        Text(account.favoriteAcct.rawValue)
                    }
                } selected: {
                    Text(account.favoriteAcct.rawValue)
                }
                
                // TODO: use date picker
                env.theme.field.text(edit, "Initial Date") {
                    TextField("Initial Date", text: $account.initialDate)
                }
                env.theme.field.text(edit, "Initial Balance") {
                    TextField("Initial Balance", value: $account.initialBal, format: .number)
                } selected: {
                    Text(account.initialBal.formatted(by: formatter))
                }
                
            }
            
            Section() {
                env.theme.field.toggle(edit, "Statement Locked") {
                    Toggle(isOn: $account.statementLocked) {
                        Text(account.statementLocked ? "YES" : "NO")
                    }
                } selected: {
                    Text(account.statementLocked ? "YES" : "NO")
                }
                // TODO: use date picker
                env.theme.field.text(edit, "Statement Date") {
                    TextField("Statement Date", text: $account.statementDate)
                }
                env.theme.field.text(edit, "Minimum Balance") {
                    TextField("Minimum Balance", value: $account.minimumBalance, format: .number)
                } selected: {
                    Text(account.minimumBalance.formatted(by: formatter))
                }
                env.theme.field.text(edit, "Credit Limit") {
                    TextField("Credit Limit", value: $account.creditLimit, format: .number)
                } selected: {
                    Text(account.creditLimit.formatted(by: formatter))
                }
                env.theme.field.text(edit, "Interest Rate") {
                    TextField("Interest Rate", value: $account.interestRate, format: .number)
                }
                // TODO: use date picker
                env.theme.field.text(edit, "Payment Due Date") {
                    TextField("Payment Due Date", text: $account.paymentDueDate)
                }
                env.theme.field.text(edit, "Minimum Payment") {
                    TextField("Minimum Payment", value: $account.minimumPayment, format: .number)
                } selected: {
                    Text(account.minimumPayment.formatted(by: formatter))
                }
            }

            Section() {
                if edit || !account.num.isEmpty {
                    env.theme.field.text(edit, "Number") {
                        TextField("Number", text: $account.num)
                            .textInputAutocapitalization(.never)
                    }
                }
                if edit || !account.heldAt.isEmpty {
                    env.theme.field.text(edit, "Held at") {
                        TextField("Held at", text: $account.heldAt)
                            .textInputAutocapitalization(.sentences)
                    }
                }
                if edit || !account.website.isEmpty {
                    env.theme.field.text(edit, "Website") {
                        TextField("Website", text: $account.website)
                            .textInputAutocapitalization(.never)
                    }
                }
                if edit || !account.contactInfo.isEmpty {
                    env.theme.field.text(edit, "Contact Info") {
                        TextField("Contact Info", text: $account.contactInfo)
                            .textInputAutocapitalization(.sentences)
                    }
                }
                if edit || !account.accessInfo.isEmpty {
                    env.theme.field.text(edit, "Access Info") {
                        TextField("Access Info", text: $account.accessInfo)
                            .textInputAutocapitalization(.sentences)
                    }
                }
            }
        
            Section() {
                env.theme.field.text(edit, "Notes") {
                    TextField("Notes", text: $account.notes)
                        .textInputAutocapitalization(.never)
                }
            }
            
            // TODO: delete account if not in use
            if true {
                Button("Delete Account") {
                    onDelete()
                }
                .foregroundColor(.red)
            }
        }
        .textSelection(.enabled)
    }
}

#Preview {
    AccountEditView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        account: .constant(AccountData.sampleData[0]),
        edit: false
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview {
    AccountEditView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        account: .constant(AccountData.sampleData[1]),
        edit: true
    )
    .environmentObject(EnvironmentManager.sampleData)
}

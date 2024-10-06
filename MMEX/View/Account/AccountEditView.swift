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
                    TextField("Cannot be empty!", text: $account.name)
                        .textInputAutocapitalization(.words)
                } show: {
                    env.theme.field.valueOrError("Cannot be empty!", text: account.name)
                }
                env.theme.field.picker(edit, "Type") {
                    Picker("", selection: $account.type) {
                        ForEach(AccountType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                } show: {
                    Text(account.type.rawValue)
                }
                env.theme.field.picker(edit, "Currency") {
                    Picker("", selection: $account.currencyId) {
                        if (account.currencyId <= 0) {
                            Text("Select Currency").tag(0 as Int64) // not set
                        }
                        ForEach(allCurrencyName, id: \.0) { id, name in
                            Text(name).tag(id)
                        }
                    }
                } show: {
                    env.theme.field.valueOrError("Select Currency!", text: currency?.name)
                }
                env.theme.field.toggle(edit, "Status") {
                    Toggle(isOn: $account.status.isOpen) { }
                } show: {
                    Text(account.status.rawValue)
                }
                env.theme.field.toggle(edit, "Favorite") {
                    Toggle(isOn: $account.favoriteAcct.asBool) { }
                } show: {
                    Text(account.favoriteAcct.rawValue)
                }
                
                env.theme.field.date(edit, "Initial Date") {
                    DatePicker("", selection: $account.initialDate.date, displayedComponents: [.date])
                } show: {
                    env.theme.field.valueOrError("Should not be empty!", text: account.initialDate.string)
                }
                env.theme.field.text(edit, "Initial Balance") {
                    TextField("Default is 0", value: $account.initialBal, format: .number)
                        .keyboardType(.decimalPad)
                } show: {
                    Text(account.initialBal.formatted(by: formatter))
                }
            }

            Section() {
                env.theme.field.toggle(edit, "Statement Locked") {
                    Toggle(isOn: $account.statementLocked) { }
                } show: {
                    Text(account.statementLocked ? "YES" : "NO")
                }
                env.theme.field.date(edit, "Statement Date") {
                    DatePicker("", selection: $account.statementDate.date, displayedComponents: [.date])
                } show: {
                    env.theme.field.valueOrHint("N/A", text: account.statementDate.string)
                }
                env.theme.field.text(edit, "Minimum Balance") {
                    TextField("Default is 0", value: $account.minimumBalance, format: .number)
                        .keyboardType(.decimalPad)
                } show: {
                    Text(account.minimumBalance.formatted(by: formatter))
                }
                env.theme.field.text(edit, "Credit Limit") {
                    TextField("Default is 0", value: $account.creditLimit, format: .number)
                        .keyboardType(.decimalPad)
                } show: {
                    Text(account.creditLimit.formatted(by: formatter))
                }
                env.theme.field.text(edit, "Interest Rate") {
                    TextField("Default is 0", value: $account.interestRate, format: .number)
                        .keyboardType(.decimalPad)
                }
                env.theme.field.date(edit, "Payment Due Date") {
                    DatePicker("", selection: $account.paymentDueDate.date, displayedComponents: [.date])
                } show: {
                    env.theme.field.valueOrHint("N/A", text: account.paymentDueDate.string)
                }
                env.theme.field.text(edit, "Minimum Payment") {
                    TextField("Default is 0", value: $account.minimumPayment, format: .number)
                        .keyboardType(.decimalPad)
                } show: {
                    Text(account.minimumPayment.formatted(by: formatter))
                }
            }

            Section() {
                if edit || !account.num.isEmpty {
                    env.theme.field.text(edit, "Number") {
                        TextField("N/A", text: $account.num)
                            .textInputAutocapitalization(.never)
                    }
                }
                if edit || !account.heldAt.isEmpty {
                    env.theme.field.text(edit, "Held at") {
                        TextField("N/A", text: $account.heldAt)
                            .textInputAutocapitalization(.sentences)
                    }
                }
                if edit || !account.website.isEmpty {
                    env.theme.field.text(edit, "Website") {
                        TextField("N/A", text: $account.website)
                            .textInputAutocapitalization(.never)
                    }
                }
                if edit || !account.contactInfo.isEmpty {
                    env.theme.field.text(edit, "Contact Info") {
                        TextField("N/A", text: $account.contactInfo)
                            .textInputAutocapitalization(.sentences)
                    }
                }
                if edit || !account.accessInfo.isEmpty {
                    env.theme.field.text(edit, "Access Info") {
                        TextField("N/A", text: $account.accessInfo)
                            .textInputAutocapitalization(.sentences)
                    }
                }
            }

            Section() {
                env.theme.field.editor(edit, "Notes") {
                    TextEditor(text: $account.notes)
                        .textInputAutocapitalization(.never)
                } show: {
                    env.theme.field.valueOrHint("N/A", text: account.notes)
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
        .onAppear {
            //print("\(env.currencyCache.count)")
        }
    }
}

#Preview("\(AccountData.sampleData[0].name) (show)") {
    AccountEditView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        account: .constant(AccountData.sampleData[0]),
        edit: false
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview("\(AccountData.sampleData[0].name) (edit)") {
    AccountEditView(
        allCurrencyName: .constant(CurrencyData.sampleDataName),
        account: .constant(AccountData.sampleData[0]),
        edit: true
    )
    .environmentObject(EnvironmentManager.sampleData)
}

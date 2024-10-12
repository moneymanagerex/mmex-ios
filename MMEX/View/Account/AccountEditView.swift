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
    @State var viewModel: AccountViewModel
    @Binding var data: AccountData
    @State var edit: Bool
    var onDelete: () -> Void = { }

    var currency: CurrencyInfo? { env.currencyCache[data.currencyId] }
    var formatter: CurrencyFormatter? { currency?.formatter }

    var body: some View {
        Form {
            Section {
                env.theme.field.text(edit, "Name") {
                    TextField("Cannot be empty!", text: $data.name)
                        .textInputAutocapitalization(.words)
                } show: {
                    env.theme.field.valueOrError("Cannot be empty!", text: data.name)
                }

                env.theme.field.picker(edit, "Type") {
                    Picker("", selection: $data.type) {
                        ForEach(AccountType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                } show: {
                    Text(data.type.rawValue)
                }

                env.theme.field.picker(edit, "Currency") {
                    Picker("", selection: $data.currencyId) {
                        if (data.currencyId <= 0) {
                            Text("Select Currency").tag(0 as Int64) // not set
                        }
                        ForEach(viewModel.currencyName, id: \.0) { id, name in
                            Text(name).tag(id)
                        }
                    }
                } show: {
                    env.theme.field.valueOrError("Cannot be empty!", text: currency?.name)
                }

                env.theme.field.toggle(edit, "Status") {
                    Toggle(isOn: $data.status.isOpen) { }
                } show: {
                    Text(data.status.rawValue)
                }

                env.theme.field.toggle(edit, "Favorite") {
                    Toggle(isOn: $data.favoriteAcct.asBool) { }
                } show: {
                    Text(data.favoriteAcct.rawValue)
                }

                env.theme.field.date(edit, "Initial Date") {
                    DatePicker("", selection: $data.initialDate.date, displayedComponents: [.date])
                } show: {
                    env.theme.field.valueOrError("Should not be empty!", text: data.initialDate.string)
                }

                env.theme.field.text(edit, "Initial Balance") {
                    TextField("Default is 0", value: $data.initialBal, format: .number)
                        .keyboardType(.decimalPad)
                } show: {
                    Text(data.initialBal.formatted(by: formatter))
                }
            }

            Section() {
                env.theme.field.toggle(edit, "Statement Locked") {
                    Toggle(isOn: $data.statementLocked) { }
                } show: {
                    Text(data.statementLocked ? "YES" : "NO")
                }

                env.theme.field.date(edit, "Statement Date") {
                    DatePicker("", selection: $data.statementDate.date, displayedComponents: [.date])
                } show: {
                    env.theme.field.valueOrHint("N/A", text: data.statementDate.string)
                }

                env.theme.field.text(edit, "Minimum Balance") {
                    TextField("Default is 0", value: $data.minimumBalance, format: .number)
                        .keyboardType(.decimalPad)
                } show: {
                    Text(data.minimumBalance.formatted(by: formatter))
                }

                env.theme.field.text(edit, "Credit Limit") {
                    TextField("Default is 0", value: $data.creditLimit, format: .number)
                        .keyboardType(.decimalPad)
                } show: {
                    Text(data.creditLimit.formatted(by: formatter))
                }

                env.theme.field.text(edit, "Interest Rate") {
                    TextField("Default is 0", value: $data.interestRate, format: .number)
                        .keyboardType(.decimalPad)
                }

                env.theme.field.date(edit, "Payment Due Date") {
                    DatePicker("", selection: $data.paymentDueDate.date, displayedComponents: [.date])
                } show: {
                    env.theme.field.valueOrHint("N/A", text: data.paymentDueDate.string)
                }

                env.theme.field.text(edit, "Minimum Payment") {
                    TextField("Default is 0", value: $data.minimumPayment, format: .number)
                        .keyboardType(.decimalPad)
                } show: {
                    Text(data.minimumPayment.formatted(by: formatter))
                }
            }

            Section() {
                if edit || !data.num.isEmpty {
                    env.theme.field.text(edit, "Number") {
                        TextField("N/A", text: $data.num)
                            .textInputAutocapitalization(.never)
                    }
                }

                if edit || !data.heldAt.isEmpty {
                    env.theme.field.text(edit, "Held at") {
                        TextField("N/A", text: $data.heldAt)
                            .textInputAutocapitalization(.sentences)
                    }
                }

                if edit || !data.website.isEmpty {
                    env.theme.field.text(edit, "Website") {
                        TextField("N/A", text: $data.website)
                            .textInputAutocapitalization(.never)
                    }
                }

                if edit || !data.contactInfo.isEmpty {
                    env.theme.field.text(edit, "Contact Info") {
                        TextField("N/A", text: $data.contactInfo)
                            .textInputAutocapitalization(.sentences)
                    }
                }

                if edit || !data.accessInfo.isEmpty {
                    env.theme.field.text(edit, "Access Info") {
                        TextField("N/A", text: $data.accessInfo)
                            .textInputAutocapitalization(.sentences)
                    }
                }
            }

            Section() {
                env.theme.field.editor(edit, "Notes") {
                    TextEditor(text: $data.notes)
                        .textInputAutocapitalization(.never)
                } show: {
                    env.theme.field.valueOrHint("N/A", text: data.notes)
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
        viewModel: AccountViewModel(env: EnvironmentManager.sampleData),
        data: .constant(AccountData.sampleData[0]),
        edit: false
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview("\(AccountData.sampleData[0].name) (edit)") {
    AccountEditView(
        viewModel: AccountViewModel(env: EnvironmentManager.sampleData),
        data: .constant(AccountData.sampleData[0]),
        edit: true
    )
    .environmentObject(EnvironmentManager.sampleData)
}

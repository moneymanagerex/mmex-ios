//
//  AccountEditView.swift
//  MMEX
//
//  2024-09-09: Created by Lisheng Guan
//  2024-10-05: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AccountEditView: View {
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @Binding var data: AccountData
    @State var edit: Bool

    var currency: CurrencyInfo? { env.currencyCache[data.currencyId] }
    var formatter: CurrencyFormatter? { currency?.formatter }

    var body: some View {
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
            
            if
                let currencyOrder = vm.currencyList.order.readyValue,
                let currencyName  = vm.currencyList.name.readyValue
            {
                env.theme.field.picker(edit, "Currency") {
                    Picker("", selection: $data.currencyId) {
                        if (data.currencyId <= 0) {
                            Text("Select Currency").tag(0 as DataId) // not set
                        }
                        ForEach(currencyOrder, id: \.self) { id in
                            Text(currencyName[id] ?? "").tag(id)
                        }
                    }
                } show: {
                    env.theme.field.valueOrError("Cannot be empty!", text: currency?.name)
                }
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
    }
}

#Preview("\(AccountData.sampleData[0].name) (show)") {
    let env = EnvironmentManager.sampleData
    Form { AccountEditView(
        vm: ViewModel(env: env),
        data: .constant(AccountData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(env)
}

#Preview("\(AccountData.sampleData[0].name) (edit)") {
    let env = EnvironmentManager.sampleData
    Form { AccountEditView(
        vm: ViewModel(env: env),
        data: .constant(AccountData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(env)
}

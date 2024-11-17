//
//  AccountFormView.swift
//  MMEX
//
//  2024-09-09: Created by Lisheng Guan
//  2024-10-05: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AccountFormView: View {
    @EnvironmentObject var env: EnvironmentManager
    var vm: ViewModel
    @Binding var data: AccountData
    @State var edit: Bool

    var currency: CurrencyInfo? { vm.currencyList.info.readyValue?[data.currencyId] }
    var formatter: CurrencyFormatter? { currency?.formatter }

    var body: some View {
        Section {
            env.theme.field.view(edit, "Name", editView: {
                TextField("Cannot be empty!", text: $data.name)
                    .textInputAutocapitalization(.words)
            }, showView: {
                env.theme.field.valueOrError("Cannot be empty!", text: data.name)
            } )
            
            env.theme.field.view(edit, false, "Type", editView: {
                Picker("", selection: $data.type) {
                    ForEach(AccountType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }, showView: {
                Text(data.type.rawValue)
            } )

            if
                let currencyOrder = vm.currencyList.order.readyValue,
                let currencyName  = vm.currencyList.name.readyValue
            {
                env.theme.field.view(edit, false, "Currency", editView: {
                    Picker("", selection: $data.currencyId) {
                        if (data.currencyId.isVoid) {
                            Text("(none)").tag(DataId.void)
                        }
                        ForEach(currencyOrder, id: \.self) { id in
                            Text(currencyName[id] ?? "").tag(id)
                        }
                    }
                }, showView: {
                    env.theme.field.valueOrError("Cannot be empty!", text: currency?.name)
                } )
            }

            env.theme.field.view(edit, true, "Status", editView: {
                Toggle(isOn: $data.status.isOpen) { }
            }, showView: {
                Text(data.status.rawValue)
            } )
            
            env.theme.field.view(edit, true, "Favorite", editView: {
                Toggle(isOn: $data.favoriteAcct.asBool) { }
            }, showView: {
                Text(data.favoriteAcct.rawValue)
            } )
            
            env.theme.field.view(edit, true, "Initial Date", editView: {
                DatePicker("", selection: $data.initialDate.date, displayedComponents: [.date])
                    .labelsHidden()
            }, showView: {
                env.theme.field.valueOrError("Should not be empty!", text: data.initialDate.string)
            } )
            
            env.theme.field.view(edit, true, "Initial Balance", editView: {
                TextField("Default is 0", value: $data.initialBal.defaultZero, format: .number)
                    .keyboardType(env.theme.decimalPad)
            }, showView: {
                Text(data.initialBal.formatted(by: formatter))
            } )
        }
        
        Section() {
            env.theme.field.view(edit, true, "Statement Locked", editView: {
                Toggle(isOn: $data.statementLocked) { }
            }, showView: {
                Text(data.statementLocked ? "YES" : "NO")
            } )
            
            env.theme.field.view(edit, true, "Statement Date", editView: {
                DatePicker("", selection: $data.statementDate.date, displayedComponents: [.date])
                    .labelsHidden()
            }, showView: {
                env.theme.field.valueOrHint("N/A", text: data.statementDate.string)
            } )
            
            env.theme.field.view(edit, true, "Minimum Balance", editView: {
                TextField("Default is 0", value: $data.minimumBalance.defaultZero, format: .number)
                    .keyboardType(env.theme.decimalPad)
            }, showView: {
                Text(data.minimumBalance.formatted(by: formatter))
            } )
            
            env.theme.field.view(edit, true, "Credit Limit", editView: {
                TextField("Default is 0", value: $data.creditLimit.defaultZero, format: .number)
                    .keyboardType(env.theme.decimalPad)
            }, showView: {
                Text(data.creditLimit.formatted(by: formatter))
            } )
            
            env.theme.field.view(edit, true, "Interest Rate", editView: {
                TextField("Default is 0", value: $data.interestRate.defaultZero, format: .number)
                    .keyboardType(env.theme.decimalPad)
            }, showView: {
                Text("\(data.interestRate)")
            } )
            
            env.theme.field.view(edit, true, "Payment Due Date", editView: {
                DatePicker("", selection: $data.paymentDueDate.date, displayedComponents: [.date])
                    .labelsHidden()
            }, showView: {
                env.theme.field.valueOrHint("N/A", text: data.paymentDueDate.string)
            } )
            
            env.theme.field.view(edit, true, "Minimum Payment", editView: {
                TextField("Default is 0", value: $data.minimumPayment.defaultZero, format: .number)
                    .keyboardType(env.theme.decimalPad)
            }, showView: {
                Text(data.minimumPayment.formatted(by: formatter))
            } )
        }
        
        Section() {
            if edit || !data.num.isEmpty {
                env.theme.field.view(edit, "Number") {
                    TextField("N/A", text: $data.num)
                        .textInputAutocapitalization(.never)
                }
            }
            
            if edit || !data.heldAt.isEmpty {
                env.theme.field.view(edit, "Held at") {
                    TextField("N/A", text: $data.heldAt)
                        .textInputAutocapitalization(.sentences)
                }
            }
            
            if edit || !data.website.isEmpty {
                env.theme.field.view(edit, "Website") {
                    TextField("N/A", text: $data.website)
                        .textInputAutocapitalization(.never)
                }
            }
            
            if edit || !data.contactInfo.isEmpty {
                env.theme.field.view(edit, "Contact Info") {
                    TextField("N/A", text: $data.contactInfo)
                        .textInputAutocapitalization(.sentences)
                }
            }
            
            if edit || !data.accessInfo.isEmpty {
                env.theme.field.view(edit, "Access Info") {
                    TextField("N/A", text: $data.accessInfo)
                        .textInputAutocapitalization(.sentences)
                }
            }
        }

        Section() {
            env.theme.field.notes(edit, "Notes", $data.notes)
        }
    }
}

#Preview("\(AccountData.sampleData[0].name) (show)") {
    let env = EnvironmentManager.sampleData
    Form { AccountFormView(
        vm: ViewModel(env: env),
        data: .constant(AccountData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(env)
}

#Preview("\(AccountData.sampleData[0].name) (edit)") {
    let env = EnvironmentManager.sampleData
    let vm = ViewModel(env: env)
    Form { AccountFormView(
        vm: vm,
        data: .constant(AccountData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(env)
}

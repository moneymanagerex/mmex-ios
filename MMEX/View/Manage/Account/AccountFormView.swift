//
//  AccountFormView.swift
//  MMEX
//
//  2024-09-09: Created by Lisheng Guan
//  2024-10-05: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AccountFormView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @Binding var data: AccountData
    @State var edit: Bool

    var currency: CurrencyInfo? { vm.currencyList.info.readyValue?[data.currencyId] }
    var formatter: CurrencyFormatter? { currency?.formatter }

    var body: some View {
        Section {
            pref.theme.field.view(edit, "Name", editView: {
                TextField("Shall not be empty!", text: $data.name)
                    .keyboardType(pref.theme.textPad)
                    .textInputAutocapitalization(.words)
            }, showView: {
                pref.theme.field.valueOrError("Shall not be empty!", text: data.name)
            } )

            pref.theme.field.view(edit, false, "Type", editView: {
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
                pref.theme.field.view(edit, false, "Currency", editView: {
                    Picker("", selection: $data.currencyId) {
                        if (data.currencyId.isVoid) {
                            Text("(none)").tag(DataId.void)
                        }
                        ForEach(currencyOrder, id: \.self) { id in
                            Text(currencyName[id] ?? "").tag(id)
                        }
                    }
                }, showView: {
                    pref.theme.field.valueOrError("Shall not be empty!", text: currency?.name)
                } )
            }

            pref.theme.field.view(edit, true, "Status", editView: {
                Toggle(isOn: $data.status.isOpen) { }
            }, showView: {
                Text(data.status.rawValue)
            } )
            
            pref.theme.field.view(edit, true, "Favorite", editView: {
                Toggle(isOn: $data.favoriteAcct.asBool) { }
            }, showView: {
                Text(data.favoriteAcct.rawValue)
            } )
            
            pref.theme.field.view(edit, true, "Initial Date", editView: {
                DatePicker("", selection: $data.initialDate.date, displayedComponents: [.date])
                    .labelsHidden()
            }, showView: {
                pref.theme.field.valueOrError("Should not be empty!", text: data.initialDate.string)
            } )
            
            pref.theme.field.view(edit, true, "Initial Balance", editView: {
                TextField("Default is 0", value: $data.initialBal.defaultZero, format: .number)
                    .keyboardType(pref.theme.decimalPad)
            }, showView: {
                Text(data.initialBal.formatted(by: formatter))
            } )
        }
        
        Section() {
            pref.theme.field.view(edit, true, "Statement Locked", editView: {
                Toggle(isOn: $data.statementLocked) { }
            }, showView: {
                Text(data.statementLocked ? "YES" : "NO")
            } )
            
            pref.theme.field.view(edit, true, "Statement Date", editView: {
                DatePicker("", selection: $data.statementDate.date, displayedComponents: [.date])
                    .labelsHidden()
            }, showView: {
                pref.theme.field.valueOrHint("N/A", text: data.statementDate.string)
            } )
            
            pref.theme.field.view(edit, true, "Minimum Balance", editView: {
                TextField("Default is 0", value: $data.minimumBalance.defaultZero, format: .number)
                    .keyboardType(pref.theme.decimalPad)
            }, showView: {
                Text(data.minimumBalance.formatted(by: formatter))
            } )
            
            pref.theme.field.view(edit, true, "Credit Limit", editView: {
                TextField("Default is 0", value: $data.creditLimit.defaultZero, format: .number)
                    .keyboardType(pref.theme.decimalPad)
            }, showView: {
                Text(data.creditLimit.formatted(by: formatter))
            } )
            
            pref.theme.field.view(edit, true, "Interest Rate", editView: {
                TextField("Default is 0", value: $data.interestRate.defaultZero, format: .number)
                    .keyboardType(pref.theme.decimalPad)
            }, showView: {
                Text("\(data.interestRate)")
            } )
            
            pref.theme.field.view(edit, true, "Payment Due Date", editView: {
                DatePicker("", selection: $data.paymentDueDate.date, displayedComponents: [.date])
                    .labelsHidden()
            }, showView: {
                pref.theme.field.valueOrHint("N/A", text: data.paymentDueDate.string)
            } )
            
            pref.theme.field.view(edit, true, "Minimum Payment", editView: {
                TextField("Default is 0", value: $data.minimumPayment.defaultZero, format: .number)
                    .keyboardType(pref.theme.decimalPad)
            }, showView: {
                Text(data.minimumPayment.formatted(by: formatter))
            } )
        }
        
        Section() {
            if edit || !data.num.isEmpty {
                pref.theme.field.view(edit, "Number") {
                    TextField("N/A", text: $data.num)
                        .keyboardType(pref.theme.textPad)
                        .textInputAutocapitalization(.never)
                }
            }
            
            if edit || !data.heldAt.isEmpty {
                pref.theme.field.view(edit, "Held at") {
                    TextField("N/A", text: $data.heldAt)
                        .keyboardType(pref.theme.textPad)
                        .textInputAutocapitalization(.sentences)
                }
            }
            
            if edit || !data.website.isEmpty {
                pref.theme.field.view(edit, "Website") {
                    TextField("N/A", text: $data.website)
                        .keyboardType(pref.theme.textPad)
                        .textInputAutocapitalization(.never)
                }
            }
            
            if edit || !data.contactInfo.isEmpty {
                pref.theme.field.view(edit, "Contact Info") {
                    TextField("N/A", text: $data.contactInfo)
                        .keyboardType(pref.theme.textPad)
                        .textInputAutocapitalization(.sentences)
                }
            }
            
            if edit || !data.accessInfo.isEmpty {
                pref.theme.field.view(edit, "Access Info") {
                    TextField("N/A", text: $data.accessInfo)
                        .keyboardType(pref.theme.textPad)
                        .textInputAutocapitalization(.sentences)
                }
            }
        }

        Section("Notes") {
            pref.theme.field.notes(edit, "", $data.notes)
                .keyboardType(pref.theme.textPad)
        }
    }
}

#Preview("\(AccountData.sampleData[0].name) (show)") {
    let pref = Preference()
    let vm = ViewModel.sampleData
    Form { AccountFormView(
        data: .constant(AccountData.sampleData[0]),
        edit: false
    ) }
    .environmentObject(pref)
    .environmentObject(vm)
}

#Preview("\(AccountData.sampleData[0].name) (edit)") {
    let pref = Preference()
    let vm = ViewModel.sampleData
    Form { AccountFormView(
        data: .constant(AccountData.sampleData[0]),
        edit: true
    ) }
    .environmentObject(pref)
    .environmentObject(vm)
}

//
//  PayeeEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import SwiftUI

struct PayeeEditView: View {
    @Binding var payee: Payee
    @Binding var categories: [Category]

    var body: some View {
        Form {
            Section(header: Text("Payee Name")) {
                TextField("Payee Name", text: $payee.name)
            }

            Section(header: Text("Category")) {
                Picker("Category", selection: Binding(
                    get: { payee.categoryId ?? 0 }, // Safely unwrap the optional notes field
                    set: { payee.categoryId = $0 } // Set
                )) {
                    ForEach(categories) { category in
                        Text(category.name).tag(category.id) // Use currency.name to display and tag by id
                    }
                }
                .labelsHidden()
                .pickerStyle(MenuPickerStyle()) // Adjust the style of the picker as needed
            }

            Section(header: Text("Number")) {
                TextField("Number", text: Binding(
                    get: { payee.number ?? "" }, // Safely unwrap the optional notes field
                    set: { payee.number = $0.isEmpty ? nil : $0 } // Set to nil if the input is empty
                ))
            }

            Section(header: Text("Website")) {
                TextField("Website", text: Binding(
                    get: { payee.website ?? "" }, // Safely unwrap the optional notes field
                    set: { payee.website = $0.isEmpty ? nil : $0 } // Set to nil if the input is empty
                ))
            }

            Section(header: Text("Notes")) {
                TextField("Notes", text: Binding(
                    get: { payee.notes ?? "" },
                    set: { payee.notes = $0.isEmpty ? nil : $0 }
                ))
            }

            Section(header: Text("Active")) {
                Toggle(isOn: Binding(get: {
                    payee.active == 1
                }, set: { newValue in
                    payee.active = newValue ? 1 : 0
                })) {
                    Text("Is Active")
                }
            }

            Section(header: Text("Pattern")) {
                TextField("Pattern", text: $payee.pattern)
            }
        }
        .navigationTitle("Edit Payee")
    }
}

#Preview {
    PayeeEditView(payee: .constant(Payee.sampleData[0]), categories: .constant(Category.sampleData))
}

#Preview {
    PayeeEditView(payee: .constant(Payee.sampleData[1]), categories: .constant(Category.sampleData))
}

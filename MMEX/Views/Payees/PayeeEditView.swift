//
//  PayeeEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//

import SwiftUI

struct PayeeEditView: View {
    @Binding var payee: PayeeData
    @Binding var categories: [CategoryData]

    var body: some View {
        Form {
            Section(header: Text("Payee Name")) {
                TextField("Payee Name", text: $payee.name)
            }

            Section(header: Text("Category")) {
                Picker("Category", selection: Binding(
                    get: { payee.categoryId }, // Safely unwrap the optional notes field
                    set: { payee.categoryId = $0 } // Set
                )) {
                    Text("Category").tag(0 as Int64) // not set
                    ForEach(categories) { category in
                        Text(category.name).tag(category.id) // Use currency.name to display and tag by id
                    }
                }
                .labelsHidden()
                .pickerStyle(MenuPickerStyle()) // Adjust the style of the picker as needed
            }

            Section(header: Text("Number")) {
                TextField("Number", text: Binding(
                    get: { payee.number }, // Safely unwrap the optional notes field
                    set: { payee.number = $0 } // Set to nil if the input is empty
                ))
            }

            Section(header: Text("Website")) {
                TextField("Website", text: Binding(
                    get: { payee.website }, // Safely unwrap the optional notes field
                    set: { payee.website = $0 } // Set to nil if the input is empty
                ))
            }

            Section(header: Text("Notes")) {
                TextField("Notes", text: Binding(
                    get: { payee.notes },
                    set: { payee.notes = $0 }
                ))
            }

            Section(header: Text("Active")) {
                Toggle(isOn: Binding(get: {
                    payee.active
                }, set: { newValue in
                    payee.active = newValue
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
    PayeeEditView(
        payee: .constant(PayeeData.sampleData[0]),
        categories: .constant(CategoryData.sampleData)
    )
}

#Preview {
    PayeeEditView(
        payee: .constant(PayeeData.sampleData[1]),
        categories: .constant(CategoryData.sampleData)
    )
}

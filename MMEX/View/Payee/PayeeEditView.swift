//
//  PayeeEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/6.
//  Edited 2024-10-05 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct PayeeEditView: View {
    @EnvironmentObject var env: EnvironmentManager
    @Binding var categories: [CategoryData]
    @Binding var payee: PayeeData
    @State var edit: Bool
    var onDelete: () -> Void = { }

    var category: CategoryData? {
        payee.categoryId >= categories.startIndex && payee.categoryId < categories.endIndex ?
        categories[Int(payee.categoryId)] : nil
    }

    var body: some View {
        Form {
            Section {
                env.theme.field.text(edit, "Name") {
                    TextField("Cannot be empty!", text: $payee.name)
                        .textInputAutocapitalization(.words)
                } show: {
                    env.theme.field.valueOrError("Cannot be empty!", text: payee.name)
                }

                env.theme.field.toggle(edit, "Active") {
                    Toggle(isOn: $payee.active) { }
                } show: {
                    Text(payee.active ? "Yes" : "No")
                }
            }

            Section {
                env.theme.field.picker(edit, "Category") {
                    Picker("", selection: $payee.categoryId) {
                        if (payee.categoryId <= 0) {
                            Text("Select Category").tag(0 as DataId) // not set
                        }
                        ForEach(categories.indices, id: \.self) { i in
                            Text(categories[i].name).tag(categories[i].id)
                        }
                    }
                } show: {
                    env.theme.field.valueOrHint("N/A", text: category?.name)
                }

                if edit || !payee.number.isEmpty {
                    env.theme.field.text(edit, "Payment Number") {
                        TextField("N/A", text: $payee.number)
                            .textInputAutocapitalization(.never)
                    }
                }

                if edit || !payee.website.isEmpty {
                    env.theme.field.text(edit, "Website") {
                        TextField("N/A", text: $payee.website)
                            .textInputAutocapitalization(.never)
                    }
                }

                if edit || !payee.pattern.isEmpty {
                    env.theme.field.text(edit, "Pattern") {
                        TextField("N/A", text: $payee.pattern)
                            .textInputAutocapitalization(.never)
                    }
                }
            }
            
            Section {
                env.theme.field.editor(edit, "Notes") {
                    TextEditor(text: $payee.notes)
                        .textInputAutocapitalization(.never)
                } show: {
                    env.theme.field.valueOrHint("N/A", text: payee.notes)
                }
            }

            // TODO: delete payee if not in use
            if true {
                Button("Delete Payee") {
                    onDelete()
                }
                .foregroundColor(.red)
            }
        }
        .textSelection(.enabled)
    }
}

#Preview("\(PayeeData.sampleData[0].name) (show)") {
    PayeeEditView(
        categories: .constant(CategoryData.sampleData),
        payee: .constant(PayeeData.sampleData[0]),
        edit: false
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview("\(PayeeData.sampleData[0].name) (edit)") {
    PayeeEditView(
        categories: .constant(CategoryData.sampleData),
        payee: .constant(PayeeData.sampleData[0]),
        edit: true
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview("\(PayeeData.sampleData[1].name) (show)") {
    PayeeEditView(
        categories: .constant(CategoryData.sampleData),
        payee: .constant(PayeeData.sampleData[1]),
        edit: false
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview("\(PayeeData.sampleData[1].name) (edit)") {
    PayeeEditView(
        categories: .constant(CategoryData.sampleData),
        payee: .constant(PayeeData.sampleData[1]),
        edit: true
    )
    .environmentObject(EnvironmentManager.sampleData)
}

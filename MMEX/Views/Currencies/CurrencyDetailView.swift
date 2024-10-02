//
//  CurrencyDetailView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/17.
//

import SwiftUI

struct DetailFieldView<Content: View>: View {
    let edit  : Bool
    let label : String
    var textField: () -> Content
    //@Binding var value: Value

    init(edit: Bool = false, label: String, @ViewBuilder textField: @escaping () -> Content) {
        self.edit   = edit
        self.label  = label
        self.textField = textField
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(label)
                .font(.body.smallCaps())
                .fontWeight(.thin)
                .dynamicTypeSize(.small)
                .padding(0)
//            TextField(empty, value: $value, format: .)
            textField()
                .padding(.top, 0.0)
                .padding(.bottom, 0.0)
                .disabled(!edit)
        }
        .padding(0)
    }
}

struct CurrencyDetailView: View {
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment
    @State var currency: CurrencyData

    @State private var editingCurrency = CurrencyData()
    @State private var isPresentingEditView = false
    @Environment(\.presentationMode) var presentationMode

    @State var edit: Bool = false
    @State var format: String = ""

    var body: some View {
        return Form {
            Section(header: Text("Currency").font(.body)) {
                DetailFieldView(edit: edit, label: "Name") {
                    TextField("Currency Name", text: $currency.name)
                }
                DetailFieldView(edit: edit, label: "Symbol") {
                    TextField("Currency Symbol", text: $currency.symbol)
                }
                if edit || !currency.unitName.isEmpty {
                    DetailFieldView(edit: edit, label: "Unit Name") {
                        TextField("Unit Name", text: $currency.unitName)
                    }
                    if edit || !currency.centName.isEmpty {
                        DetailFieldView(edit: edit, label: "Cent Name") {
                            TextField("Cent Name", text: $currency.centName)
                        }
                    }
                }
                if edit {
                    DetailFieldView(edit: edit, label: "Prefix Symbol") {
                        TextField("Prefix Symbol", text: $currency.prefixSymbol)
                    }
                    DetailFieldView(edit: edit, label: "Suffix Symbol") {
                        TextField("Suffix Symbol", text: $currency.suffixSymbol)
                    }
                    DetailFieldView(edit: edit, label: "Decimal Point") {
                        TextField("Decimal Point", text: $currency.decimalPoint)
                    }
                    DetailFieldView(edit: edit, label: "Thousands Separator") {
                        TextField("Thousands Separator", text: $currency.groupSeparator)
                    }
                    DetailFieldView(edit: edit, label: "Scale") {
                        TextField("Scale", value: $currency.scale, format: .number)
                    }
                } else {
                    DetailFieldView(edit: edit, label: "Format") {
                        TextField("", text: $format)
                    }
                }
                
                /*
                Section(header: Text("Conversion Rate")) {
                    TextField("Conversion Rate", value: $currency.baseConvRate, format: .number)
                }
                Section(header: Text("Type")) {
                    Picker("Currency Type", selection: $currency.type) {
                        ForEach(CurrencyType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle()) // Adjust the style of the picker as needed
                }

                */

                //DetailTextFieldView(edit: edit, label: "Conversion Rate", value: $currency.baseConvRate)
                //DetailTextFieldView(edit: edit, label: "Type", value: $currency.type.rawValue)
            }
        }
        .onAppear {
            let amount: Double = 12345.67
            format = amount.formatted(by: currency.formatter)
        }
    }
    
    var body2: some View {
        List {
            Section(header: Text("Name")) {
                Text(currency.name)
            }
            Section(header: Text("Symbol")) {
                Text(currency.symbol)
            }

            if !currency.unitName.isEmpty {
                Section(header: Text("Unit Name")) {
                    Text(currency.unitName)
                }
                if !currency.centName.isEmpty {
                    Section(header: Text("Cent Name")) {
                        Text(currency.centName)
                    }
                }
            }

            Section(header: Text("Format")) {
                let amount: Double = 12345.67
                Text(amount.formatted(by: currency.formatter))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
/*
            Section(header: Text("Prefix Symbol")) {
                Text(currency.prefixSymbol)
            }
            Section(header: Text("Suffix Symbol")) {
                Text(currency.suffixSymbol)
            }
            Section(header: Text("Scale")) {
                Text("\(currency.scale)")
            }
*/

            Section(header: Text("Conversion Rate")) {
                Text("\(currency.baseConvRate)")
            }
            Section(header: Text("Type")) {
                Text(currency.type.rawValue)
            }
            // cannot delete currency in use
            if dataManager.currencyCache[currency.id] == nil {
                Button("Delete Currency") {
                    deleteCurrency()
                }
            }
        }
        .textSelection(.enabled)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isPresentingEditView = true
                    editingCurrency = currency
                }
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                CurrencyEditView(
                    currency: $editingCurrency
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isPresentingEditView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            isPresentingEditView = false
                            currency = editingCurrency
                            updateCurrency()
                        }
                    }
                }
            }
        }
    }

    func updateCurrency() {
        guard let repository = dataManager.currencyRepository else { return }
        if repository.update(currency) {
            if dataManager.currencyCache[currency.id] != nil {
                dataManager.currencyCache.update(id: currency.id, data: currency)
            }
            // Handle success
        } else {
            // Handle failure
        }
    }

    func deleteCurrency() {
        guard dataManager.currencyCache[currency.id] == nil else { return }
        guard let repository = dataManager.currencyRepository else { return }
        if repository.delete(currency) {
            presentationMode.wrappedValue.dismiss()
        } else {
            // Handle deletion failure
        }
    }
}

#Preview {
    CurrencyDetailView(
        currency: CurrencyData.sampleData[0]
    )
    .environmentObject(DataManager.sampleDataManager)
}

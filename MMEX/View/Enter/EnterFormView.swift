//
//  EnterFormView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct EnterFormView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @Binding var focus: Bool
    @Binding var txn: TransactionData

    @FocusState var focusState: Int?
    @State private var selectedDate = Date()
    @State private var newSplit: TransactionSplitData = TransactionSplitData() // TODO: set default category ?

    var body: some View {
        VStack {
            // 1. Transaction type picker (Deposit/Withdrawal/Transfer)
            HStack {
                Picker("", selection: $txn.transCode) {
                    ForEach(TransactionType.allCases) { transCode in
                        Text(transCode.name).tag(transCode)
                    }
                }
                .padding(0)
                // do not use segmented style, in order to avoid truncation in smaller displays
                //.pickerStyle(SegmentedPickerStyle())

                Spacer()

                Picker("Select account", selection: $txn.accountId) {
                    if (txn.accountId.isVoid) {
                        Text("Account:").tag(DataId.void)
                    }
                    ForEach(vm.accountList.order.readyValue ?? [], id: \.self) { id in
                        if let account = vm.accountList.data.readyValue?[id] {
                            Text(account.name).tag(id)
                        }
                    }
                }
            }
            .padding(.horizontal, 0)

            // 2. Unified Numeric Input for the Amount with automatic keyboard focus
            TextField("", value: $txn.transAmount, format: .number)
                .focused($focusState, equals: 1)
                .keyboardType(pref.theme.decimalPad) // Show numeric keyboard with decimal support
                .font(.system(size: 48, weight: .bold)) // Large, bold text for amount input
                .multilineTextAlignment(.center) // Center the text for better UX
                .padding()
                .background(Color.gray.opacity(0.2)) // Background styling for the input field
                .foregroundColor(!txn.splits.isEmpty ? .gray : .primary)
                .cornerRadius(10) // Rounded corners
                .padding(.bottom, 0) // Space between the amount input and the next section
                .disabled(!txn.splits.isEmpty)
                .onChange(of: txn.transAmount) {
                    txn.toTransAmount = txn.transAmount
                }
            
            // 3. Input field for notes
            TextField("Add Note", text: Binding(
                get: { txn.notes }, // Safely unwrap the optional notes field
                set: { txn.notes = $0 } // Set notes to nil if the input is empty
            ))
            .focused($focusState, equals: 2)
            .keyboardType(pref.theme.textPad)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.2)) // Style the notes input field
            .cornerRadius(10)
            .padding(.top, 0)
            
            // 4. Horizontal stack for date picker and status picker
            HStack {
                // Date Picker to select transaction date and time
                DatePicker("Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden() // Hide the default label to save space
                    .onChange(of: selectedDate) { _, newDate in
                        // Format the date as 'YYYY-MM-DDTHH:MM:SS'
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        txn.transDate.string = formatter.string(from: newDate) // Save as ISO-8601 formatted string without TZ
                    }
                
                Spacer()
                
                // Transaction status picker
                Menu(content: {
                    Picker("Transaction Status", selection: $txn.status) {
                        ForEach(TransactionStatus.allCases) { status in
                            Text(status.fullName).tag(status)
                        }
                    }
                }, label: { (
                    Text("\(txn.status.shortName) ") +
                    Text(Image(systemName: "chevron.up.chevron.down"))
                ) } )

            }
            .padding(.horizontal, 0)

            // 5. Horizontal stack for Payee and Category pickers
            HStack {
                if txn.transCode == .transfer {
                    // to Account picker
                    Picker("Select To Account", selection: $txn.toAccountId) {
                        if (txn.toAccountId.isVoid) {
                            Text("Account:").tag(DataId.void)
                        }
                        ForEach(vm.accountList.order.readyValue ?? [], id: \.self) { id in
                            if let account = vm.accountList.data.readyValue?[id],
                               id != txn.accountId
                            {
                                Text(account.name).tag(id)
                            }
                        }
                    }
                } else {
                    // Payee picker
                    Picker("Select Payee", selection: $txn.payeeId) {
                        if (txn.payeeId.isVoid) {
                            Text("Payee:").tag(DataId.void)
                        }
                        ForEach(vm.payeeList.order.readyValue ?? []) { id in
                            if let payee = vm.payeeList.data.readyValue?[id] {
                                Text(payee.name).tag(payee.id)
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // Show a menu for the payee picker
                }
                Spacer()

                // Category picker
                Picker("Select Category", selection: $txn.categId) {
                    if (txn.categId.isVoid) {
                        Text("Category:").tag(DataId.void)
                    }
                    ForEach(vm.categoryList.evalTree.readyValue?.order ?? [], id: \.dataId) { node in
                        if let path = vm.categoryList.evalPath.readyValue?[node.dataId] {
                            Text(path).tag(node.dataId)
                        }
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Show a menu for the category picker
                .disabled(!txn.splits.isEmpty)
            }
            .padding(.horizontal, 0)
            
            // 6. Splits Section
            if txn.transCode != .transfer {
                Form {
                    Section(header: Text("Splits")) {
                        HStack {
                            Text("Category")
                                .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                            Text("Amount")
                                .frame(width: 60, alignment: .center) // Centered with fixed width
                            Text("Notes")
                                .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 0)

                        ForEach(txn.splits.indices, id: \.self) { index in
                            let split = txn.splits[index]
                            HStack {
                                Text(vm.categoryList.evalPath.readyValue?[split.categId] ?? "")
                                    .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                                Text(split.amount.formatted(
                                    by: vm.currencyList.info.readyValue?[
                                        vm.accountList.data.readyValue?[txn.accountId]?.currencyId ?? .void
                                    ]?.formatter
                                ))
                                .frame(width: 60, alignment: .center) // Centered with fixed width
                                Text(split.notes)
                                    .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                            }
                        }
                        .onDelete { indices in
                            txn.splits.remove(atOffsets: indices)
                            txn.transAmount = txn.splits.reduce(0.0) { $0 + $1.amount }
                        }

                        HStack {
                            // Split Category picker
                            Picker("Select Category", selection: $newSplit.categId) {
                                if (newSplit.categId.isVoid) {
                                    Text("Category:").tag(DataId.void)
                                }
                                ForEach(vm.categoryList.evalTree.readyValue?.order ?? [], id: \.dataId) { node in
                                    if let path = vm.categoryList.evalPath.readyValue?[node.dataId] {
                                        Text(path).tag(node.dataId)
                                    }
                                }
                            }
                            .pickerStyle(MenuPickerStyle()) // Show a menu for the category picker
                            .labelsHidden()
                            .disabled(!txn.categId.isVoid)
                            .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                            Spacer()
                            // Split amount
                            TextField("split amount", value: $newSplit.amount, format: .number)
                                .focused($focusState, equals: 3)
                                .keyboardType(pref.theme.decimalPad)
                                .multilineTextAlignment(.center) // Center the text for better UX
                                .frame(width: 60, alignment: .center) // Centered with fixed width
                            Spacer()
                            // split notes
                            TextField("split notes", text: $newSplit.notes)
                                .focused($focusState, equals: 4)
                                .keyboardType(pref.theme.textPad)
                                .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                            Button(action: {
                                withAnimation {
                                    txn.splits.append(newSplit)
                                    txn.transAmount = txn.splits.reduce(0.0) { $0 + $1.amount }
                                    newSplit = TransactionSplitData()
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .accessibilityLabel("Add split")
                            }
                            .disabled(newSplit.categId.isVoid || !txn.categId.isVoid)
                        }
                        .labelsHidden()
                    }
                    .listRowInsets(EdgeInsets())
                }
                .padding(.vertical, 0)
            }

            Spacer() // Push the contents to the top
        }
        .keyboardState(focus: $focus, focusState: $focusState)
        .padding(.horizontal)

        .onAppear {
            // Initialize state variables from the txn object when the view appears
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            selectedDate = dateFormatter.date(from: txn.transDate.string) ?? Date()
            Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                focusState = 1
            }
        }
        .onDisappear {
            focusState = nil
        }
    }
}

#Preview("[0]") {
    MMEXPreview.enter(
        TransactionData.sampleData[0]
    )
}

#Preview("[3]") {
    MMEXPreview.enter(
        TransactionData.sampleData[3]
    )
}

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

    @State private var editSplitData = TransactionSplitData()
    @State private var editingSplitIndex: Int? = nil
    @State private var showingSplitEditor = false

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
                        .padding(.horizontal, 0)

                        ForEach(txn.splits.indices, id: \.self) { index in
                            let split = txn.splits[index]
                            Button {
                                editSplitData = split          // 复制当前值
                                editingSplitIndex = index
                                showingSplitEditor = true      // 显示 sheet
                            } label: {
                                HStack {
                                    Text(vm.categoryList.evalPath.readyValue?[split.categId] ?? "")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.primary)
                                    Text(split.amount.formatted(
                                        by: vm.currencyList.info.readyValue?[
                                            vm.accountList.data.readyValue?[txn.accountId]?.currencyId ?? .void
                                        ]?.formatter
                                    ))
                                    .frame(width: 60, alignment: .center)
                                    Text(split.notes)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .contentShape(Rectangle())      // 扩大点击区域
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { indices in
                            txn.splits.remove(atOffsets: indices)
                            txn.transAmount = txn.splits.reduce(0.0) { $0 + $1.amount }
                        }

                        Button {
                            editSplitData = TransactionSplitData()
                            editingSplitIndex = nil
                            showingSplitEditor = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .disabled(!txn.categId.isVoid)
                        .accessibilityLabel("Add split")   // 保证 VoiceOver 可用
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
        .background(
            // 必须将 sheet 放在某个视图上，可以是 VStack 或 body 最外层
            EmptyView()
        )
        .sheet(isPresented: $showingSplitEditor) {
            SplitEditView(
                split: $editSplitData,
                onSave: { updatedSplit in
                    if let idx = editingSplitIndex {
                        txn.splits[idx] = updatedSplit
                    } else {
                        txn.splits.append(updatedSplit)
                    }
                    txn.transAmount = txn.splits.reduce(0.0) { $0 + $1.amount }
                    // dismiss 会在 SplitEditView 内部调用，这里不需要
                },
                onDelete: editingSplitIndex != nil ? {
                    if let idx = editingSplitIndex {
                        txn.splits.remove(at: idx)
                        txn.transAmount = txn.splits.reduce(0.0) { $0 + $1.amount }
                    }
                } : nil
            )
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

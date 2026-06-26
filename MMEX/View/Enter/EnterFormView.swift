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
    @Binding var journal: JournalData

    @FocusState var focusState: Int?

    @State private var editSplitData = JournalSplitData()
    @State private var editingSplitIndex: Int? = nil
    @State private var showingSplitEditor = false

    var body: some View {
        VStack {
            // 0. (Transaction / Scheduled）
            Picker("Type", selection: $journal.type) {
                Text("Transaction").tag(JournalType.transaction)
                Text("Scheduled").tag(JournalType.scheduled)
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 4)
            .disabled(!journal.id.isVoid)
            
            // 1. Transaction type picker (Deposit/Withdrawal/Transfer)
            HStack {
                Picker("", selection: $journal.transCode) {
                    ForEach(TransactionType.allCases) { transCode in
                        Text(transCode.name).tag(transCode)
                    }
                }
                .padding(0)
                // do not use segmented style, in order to avoid truncation in smaller displays
                //.pickerStyle(SegmentedPickerStyle())

                Spacer()

                Picker("Select account", selection: $journal.accountId) {
                    if (journal.accountId.isVoid) {
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
            TextField("", value: $journal.transAmount, format: .number)
                .focused($focusState, equals: 1)
                .keyboardType(pref.theme.decimalPad) // Show numeric keyboard with decimal support
                .font(.system(size: 48, weight: .bold)) // Large, bold text for amount input
                .multilineTextAlignment(.center) // Center the text for better UX
                .padding()
                .background(Color.gray.opacity(0.2)) // Background styling for the input field
                .foregroundColor(!journal.splits.isEmpty ? .gray : .primary)
                .cornerRadius(10) // Rounded corners
                .padding(.bottom, 0) // Space between the amount input and the next section
                .disabled(!journal.splits.isEmpty)
                .onChange(of: journal.transAmount) {
                    journal.toTransAmount = journal.transAmount
                }
            
            // 3. Input field for notes
            TextField("Add Note", text: Binding(
                get: { journal.notes }, // Safely unwrap the optional notes field
                set: { journal.notes = $0 } // Set notes to nil if the input is empty
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
                DatePicker("Date", selection: $journal.transDate.date, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden() // Hide the default label to save space
                    .onChange(of: journal.transDate.date) { _, newDate in
                    }
                
                Spacer()
                
                // Transaction status picker
                Menu(content: {
                    Picker("Transaction Status", selection: $journal.status) {
                        ForEach(TransactionStatus.allCases) { status in
                            Text(status.fullName).tag(status)
                        }
                    }
                }, label: { (
                    Text("\(journal.status.shortName) ") +
                    Text(Image(systemName: "chevron.up.chevron.down"))
                ) } )

            }
            .padding(.horizontal, 0)

            // 5. Horizontal stack for Payee and Category pickers
            HStack {
                if journal.transCode == .transfer {
                    // to Account picker
                    Picker("Select To Account", selection: $journal.toAccountId) {
                        if (journal.toAccountId.isVoid) {
                            Text("Account:").tag(DataId.void)
                        }
                        ForEach(vm.accountList.order.readyValue ?? [], id: \.self) { id in
                            if let account = vm.accountList.data.readyValue?[id],
                               id != journal.accountId
                            {
                                Text(account.name).tag(id)
                            }
                        }
                    }
                } else {
                    // Payee picker
                    Picker("Select Payee", selection: $journal.payeeId) {
                        if (journal.payeeId.isVoid) {
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
                Picker("Select Category", selection: $journal.categId) {
                    if (journal.categId.isVoid) {
                        Text("Category:").tag(DataId.void)
                    }
                    ForEach(vm.categoryList.evalTree.readyValue?.order ?? [], id: \.dataId) { node in
                        if let path = vm.categoryList.evalPath.readyValue?[node.dataId] {
                            Text(path).tag(node.dataId)
                        }
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Show a menu for the category picker
                .disabled(!journal.splits.isEmpty)
            }
            .padding(.horizontal, 0)
            
            // 6.
            if journal.type == .scheduled {
                Group {
                    Divider()
                    Text("Recurring Settings").font(.headline)
                    HStack {
                        Picker("Repeat", selection: $journal.repeatAuto) {
                            ForEach(RepeatAuto.allCases) { auto in
                                Text(auto.name).tag(auto)
                            }
                        }
                        Spacer()
                        if journal.repeatAuto != .none {
                            Picker("Frequency", selection: $journal.repeatType) {
                                ForEach(RepeatType.allCases) { type in
                                    Text(type.name).tag(type)
                                }
                            }
                        }
                    }
                    if journal.repeatAuto != .none {
                        HStack {
                            Text("Occurrences")
                            Spacer()
                            HStack(spacing: 4) {
                                TextField("", value: $journal.repeatNum, format: .number)
                                    .frame(width: 50)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.numberPad)
                                    .disabled(journal.repeatNum == -1)  // 无限时不可编辑

                                Text(journal.repeatNum == -1 ? "∞" : "times")
                                    .foregroundColor(journal.repeatNum == -1 ? .accentColor : .secondary)
                                    .onTapGesture {
                                        // 切换无限模式
                                        if journal.repeatNum == -1 {
                                            journal.repeatNum = 1
                                        } else {
                                            journal.repeatNum = -1
                                        }
                                    }
                            }
                        }
                    }
                    DatePicker("Next Due Date", selection: $journal.dueDate.date, displayedComponents: [.date])
                        .onChange(of: journal.dueDate.date) { _, newDate in
                            journal.transDate.date = newDate
                        }
                }
            }
            
            // 7. Splits Section
            if journal.transCode != .transfer {
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

                        ForEach(journal.splits.indices, id: \.self) { index in
                            let split = journal.splits[index]
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
                                            vm.accountList.data.readyValue?[journal.accountId]?.currencyId ?? .void
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
                            journal.splits.remove(atOffsets: indices)
                            journal.transAmount = journal.splits.reduce(0.0) { $0 + $1.amount }
                        }

                        Button {
                            editSplitData = JournalSplitData()
                            editingSplitIndex = nil
                            showingSplitEditor = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .disabled(!journal.categId.isVoid)
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
            // Initialize state variables from the journal object when the view appears
            Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                focusState = 1
            }
        }
        .onDisappear {
            focusState = nil
        }
        .sheet(isPresented: $showingSplitEditor) {
            SplitEditView(
                split: $editSplitData,
                onSave: { updatedSplit in
                    if let idx = editingSplitIndex {
                        journal.splits[idx] = updatedSplit
                    } else {
                        journal.splits.append(updatedSplit)
                    }
                    journal.transAmount = journal.splits.reduce(0.0) { $0 + $1.amount }
                    // dismiss 会在 SplitEditView 内部调用，这里不需要
                },
                onDelete: editingSplitIndex != nil ? {
                    if let idx = editingSplitIndex {
                        journal.splits.remove(at: idx)
                        journal.transAmount = journal.splits.reduce(0.0) { $0 + $1.amount }
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

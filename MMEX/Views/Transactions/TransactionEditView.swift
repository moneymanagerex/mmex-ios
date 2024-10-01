//
//  TransactionEditView2.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionEditView: View {
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment
    @Binding var accountId: [Int64] // sorted by name
    @Binding var categories: [CategoryData]
    @Binding var payees: [PayeeData]
    @Binding var txn: TransactionData

    @State private var amountString: String = "0" // Temporary storage for numeric input as a string
    @State private var selectedDate = Date()

    @State private var newSplit: TransactionSplitData = TransactionSplitData() // TODO: set default category ?

    // app level setting
    @AppStorage("defaultPayeeSetting") private var defaultPayeeSetting: DefaultPayeeSetting = .none
    @AppStorage("defaultStatus") private var defaultStatus = TransactionStatus.defaultValue

    // Focus state for the Amount input to control keyboard focus
    @FocusState private var isAmountFocused: Bool
    
    var body: some View {
        VStack {
            // 1. Transaction type picker (Deposit/Withdrawal/Transfer)
            HStack {
                Picker("", selection: $txn.transCode) {
                    ForEach(TransactionType.allCases) { transCode in
                        Text(transCode.name).tag(transCode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle()) // Use a segmented style for the picker
                
                Spacer()
                
                Picker("Select account", selection: $txn.accountId) {
                    if (txn.accountId == 0) {
                        Text("Account").tag(0 as Int64) // not set
                    }
                    ForEach(accountId, id: \.self) { id in
                        if let account = dataManager.accountCache[id] {
                            Text(account.name).tag(id)
                        }
                    }
                }
            }
            .padding(.horizontal, 0)

            // 2. Unified Numeric Input for the Amount with automatic keyboard focus
            TextField("0", text: $amountString)
                .keyboardType(.decimalPad) // Show numeric keyboard with decimal support
                .font(.system(size: 48, weight: .bold)) // Large, bold text for amount input
                .multilineTextAlignment(.center) // Center the text for better UX
                .padding()
                .background(Color.gray.opacity(0.2)) // Background styling for the input field
                .cornerRadius(10) // Rounded corners
                .padding(.bottom, 0) // Space between the amount input and the next section
                .focused($isAmountFocused)  // Bind the focus state to trigger keyboard display
                .onAppear {
                    // Automatically focus on the amount field when the view appears
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isAmountFocused = true
                    }
                }
                .onChange(of: amountString) { _, newValue in
                    // Update the transaction amount in the txn object, converting from String
                    txn.transAmount = Double(newValue) ?? 0.0
                }
                .disabled(!txn.splits.isEmpty)
            
            // 3. Input field for notes
            TextField("Add Note", text: Binding(
                get: { txn.notes }, // Safely unwrap the optional notes field
                set: { txn.notes = $0 } // Set notes to nil if the input is empty
            ))
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
                        txn.transDate = formatter.string(from: newDate) // Save as ISO-8601 formatted string without TZ
                    }
                
                Spacer()
                
                // Transaction status picker
                Picker("Transaction Status", selection: $txn.status) {
                    ForEach(TransactionStatus.allCases) { status in
                        Text(status.id).tag(status)
                    }
                }
            }
            .padding(.horizontal, 0)

            // 5. Horizontal stack for Payee and Category pickers
            HStack {
                if txn.transCode == .transfer {
                    // to Account picker
                    Picker("Select To Account", selection: $txn.toAccountId) {
                        if (txn.toAccountId == 0) {
                            Text("Account").tag(0 as Int64) // not set
                        }
                        ForEach(accountId, id: \.self) { id in
                            if let account = dataManager.accountCache[id],
                               id != txn.accountId
                            {
                                Text(account.name).tag(id)
                            }
                        }
                    }
                }
                else {
                    // Payee picker
                    Picker("Select Payee", selection: $txn.payeeId) {
                        if (txn.payeeId == 0) {
                            Text("Payee").tag(0 as Int64) // not set
                        }
                        ForEach(payees) { payee in
                            Text(payee.name).tag(payee.id)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // Show a menu for the payee picker
                }
                Spacer()

                // Category picker
                Picker("Select Category", selection: Binding(
                    get: { txn.categId }, // Safely unwrap the optional notes field
                    set: { txn.categId = $0 } // Set
                )) {
                    if (txn.categId == 0 ) {
                        Text("Category").tag(0 as Int64) // not set
                    }
                    ForEach(categories) { category in
                        Text(category.name).tag(category.id)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Show a menu for the category picker
                .disabled(!txn.splits.isEmpty)
            }
            .padding(.horizontal, 0)
            
            // 6. Splits Section
            if txn.transCode != TransactionType.transfer {
                Form {
                    Section(header: Text("Splits")) {
                        HStack {
                            Text("Category")
                                .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                            Text("Amount")
                                .frame(width: 80, alignment: .center) // Centered with fixed width
                            Text("Notes")
                                .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                        }
                        .padding(.horizontal, 0)

                        ForEach(txn.splits) { split in
                            HStack {
                                Text(getCategoryName(for: split.categId))
                                    .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                                Text(split.amount.formatted(
                                    by: dataManager.currencyCache[dataManager.accountCache[txn.accountId]?.currencyId ?? 0]?.formatter
                                ))
                                .frame(width: 80, alignment: .center) // Centered with fixed width
                                Text(split.notes)
                                    .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                            }
                        }
                        .onDelete { indices in
                            txn.splits.remove(atOffsets: indices)
                        }

                        HStack {
                            // Split Category picker
                            Picker("Select Category", selection: $newSplit.categId) {
                                if (newSplit.categId == 0 ) {
                                    Text("Category").tag(0 as Int64) // not set
                                }
                                ForEach(categories) { category in
                                    Text(category.name).tag(category.id)
                                }
                            }
                            .pickerStyle(MenuPickerStyle()) // Show a menu for the category picker
                            .labelsHidden()
                            .disabled(txn.categId > 0)
                            .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                            // Split amount
                            NumericField(value: $newSplit.amount)
                                .frame(width: 80, alignment: .center) // Centered with fixed width
                            // split notes
                            TextField("split notes", text: $newSplit.notes)
                                .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                            Button(action: {
                                withAnimation {
                                    txn.splits.append(newSplit)
                                    newSplit = TransactionSplitData()
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .accessibilityLabel("Add split")
                            }
                            .disabled(newSplit.categId <= 0 || txn.categId > 0)
                        }
                        .labelsHidden()
                    }
                }
                .padding(.vertical, 0)
            }

            Spacer() // Push the contents to the top
        }
        .padding(.horizontal)
        .onAppear {
            // Initialize state variables from the txn object when the view appears
            amountString = String(format: "%.2f", txn.transAmount)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            selectedDate = dateFormatter.date(from: txn.transDate) ?? Date()

            // Automatically set if there's only one item in the list
            if self.payees.count == 1 {
                txn.payeeId = self.payees.first!.id
            } else if (defaultPayeeSetting == DefaultPayeeSetting.lastUsed) {
                loadLatestTxn()
            }

            if accountId.count == 1 {
                txn.accountId = accountId.first!
            }

            if self.categories.count == 1 {
                txn.categId = self.categories.first!.id
            }

            if (txn.id == 0) {
                txn.status = defaultStatus
            }
        }
        .onDisappear {
            // Resign the focus when the view disappears, hiding the keyboard
            isAmountFocused = false
        }
    }

    func loadLatestTxn() {
        if let latestTxn = dataManager.transactionRepository?.latest(accountID: txn.accountId) ?? dataManager.transactionRepository?.latest() {
            // Update UI on the main thread
            DispatchQueue.main.async {
                if (defaultPayeeSetting == DefaultPayeeSetting.lastUsed && txn.payeeId == 0) {
                    txn.payeeId = latestTxn.payeeId
                    // txn.categId = latestTxn.categId
                }
            }
        }
    }
    func getCategoryName(for categoryID: Int64) -> String {
        return categories.first {$0.id == categoryID}?.name ?? "Unknown"
    }
}

struct NumericField: View {
    @Binding var value: Double // Bind a Double value directly

    var body: some View {
        TextField("0", value: $value, format: .number)
            .keyboardType(.decimalPad) // Show numeric keyboard
            .multilineTextAlignment(.center) // Center text alignment for better UX
            .padding(.bottom, 0) // Add bottom padding
    }
}

#Preview {
    TransactionEditView(
        accountId: .constant(AccountData.sampleDataIds),
        categories: .constant(CategoryData.sampleData),
        payees: .constant(PayeeData.sampleData),
        txn: .constant(TransactionData.sampleData[0])
    )
    .environmentObject(DataManager.sampleDataManager)
}

#Preview {
    TransactionEditView(
        accountId: .constant(AccountData.sampleDataIds),
        categories: .constant(CategoryData.sampleData),
        payees: .constant(PayeeData.sampleData),
        txn: .constant(TransactionData.sampleData[3])
    )
    .environmentObject(DataManager.sampleDataManager)
}

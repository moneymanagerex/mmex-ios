//
//  TransactionEditView2.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionEditView: View {
    @EnvironmentObject var env: EnvironmentManager // Access EnvironmentManager
    @ObservedObject var viewModel: TransactionViewModel
    @Binding var accountId: [DataId] // sorted by name
    @Binding var categories: [CategoryData]
    @Binding var payees: [PayeeData]
    @Binding var txn: TransactionData

    @State private var selectedDate = Date()

    @State private var newSplit: TransactionSplitData = TransactionSplitData() // TODO: set default category ?
    @State private var categoryUsed: Set<DataId> = []

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
                .padding(0)
                // do not use segmented style, in order to avoid truncation in smaller displays
                //.pickerStyle(SegmentedPickerStyle())

                Spacer()

                Picker("Select account", selection: $txn.accountId) {
                    if (txn.accountId.isVoid) {
                        Text("Account").tag(DataId.void)
                    }
                    ForEach(accountId, id: \.self) { id in
                        if let account = env.accountCache[id] {
                            Text(account.name).tag(id)
                        }
                    }
                }
            }
            .padding(.horizontal, 0)

            // 2. Unified Numeric Input for the Amount with automatic keyboard focus
            TextField("", value: $txn.transAmount, format: .number)
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
                            Text("Account").tag(DataId.void)
                        }
                        ForEach(accountId, id: \.self) { id in
                            if let account = env.accountCache[id],
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
                        if (txn.payeeId.isVoid) {
                            Text("Payee").tag(DataId.void)
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
                    if (txn.categId.isVoid) {
                        Text("Category").tag(DataId.void) // not set
                    }
                    ForEach(categories) { category in
                        Text(category.fullName(with: viewModel.categDelimiter)).tag(category.id)
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

                        ForEach(txn.splits, id: \.self.categId) { split in
                            HStack {
                                Text(getCategoryName(for: split.categId))
                                    .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                                Text(split.amount.formatted(
                                    by: env.currencyCache[env.accountCache[txn.accountId]?.currencyId ?? .void]?.formatter
                                ))
                                .frame(width: 80, alignment: .center) // Centered with fixed width
                                Text(split.notes)
                                    .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                            }
                        }
                        .onDelete { indices in
                            txn.splits.remove(atOffsets: indices)
                            categoryUsed = []
                            for split in txn.splits {
                                categoryUsed.insert(split.categId)
                            }
                            txn.transAmount = txn.splits.reduce(0.0) { $0 + $1.amount }
                        }

                        HStack {
                            // Split Category picker
                            Picker("Select Category", selection: $newSplit.categId) {
                                if (newSplit.categId.isVoid) {
                                    Text("Category").tag(DataId.void)
                                }
                                ForEach(categories) { category in
                                    if !categoryUsed.contains(category.id) {
                                        Text(category.fullName(with: viewModel.categDelimiter)).tag(category.id)
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
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center) // Center the text for better UX
                                .frame(width: 80, alignment: .center) // Centered with fixed width
                            Spacer()
                            // split notes
                            TextField("split notes", text: $newSplit.notes)
                                .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                            Button(action: {
                                withAnimation {
                                    txn.splits.append(newSplit)
                                    categoryUsed.insert(newSplit.categId)
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
                }
                .padding(.vertical, 0)
            }

            Spacer() // Push the contents to the top
        }
        .padding(.horizontal)
        .onAppear {
            // Initialize state variables from the txn object when the view appears
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            selectedDate = dateFormatter.date(from: txn.transDate.string) ?? Date()

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

            if (txn.id.isVoid) {
                txn.status = defaultStatus
            }

            categoryUsed = []
            for split in txn.splits {
                categoryUsed.insert(split.categId)
            }
        }
        .onDisappear {
            // Resign the focus when the view disappears, hiding the keyboard
            isAmountFocused = false
        }
    }

    func loadLatestTxn() {
        let repository = TransactionRepository(env)
        if let latestTxn = repository?.latest(accountID: txn.accountId).toOptional() ?? repository?.latest().toOptional() {
            // Update UI on the main thread
            DispatchQueue.main.async {
                if (defaultPayeeSetting == DefaultPayeeSetting.lastUsed && txn.payeeId.isVoid) {
                    txn.payeeId = latestTxn.payeeId
                    // txn.categId = latestTxn.categId
                }
            }
        }
    }

    func getCategoryName(for categoryID: DataId) -> String {
        return categories.first {$0.id == categoryID}?.fullName(with: viewModel.categDelimiter) ?? "Unknown"
    }
}

#Preview("txn 0") {
    TransactionEditView(
        viewModel: TransactionViewModel(env: EnvironmentManager.sampleData),
        accountId: .constant(AccountData.sampleDataIds),
        categories: .constant(CategoryData.sampleData),
        payees: .constant(PayeeData.sampleData),
        txn: .constant(TransactionData.sampleData[0])
    )
    .environmentObject(EnvironmentManager.sampleData)
}

#Preview("txn 3") {
    TransactionEditView(
        viewModel: TransactionViewModel(env: EnvironmentManager.sampleData),
        accountId: .constant(AccountData.sampleDataIds),
        categories: .constant(CategoryData.sampleData),
        payees: .constant(PayeeData.sampleData),
        txn: .constant(TransactionData.sampleData[3])
    )
    .environmentObject(EnvironmentManager.sampleData)
}

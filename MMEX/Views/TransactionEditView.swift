//
//  TransactionEditView2.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionEditView: View {
    @Binding var txn: Transaction
    @State private var amountString: String = "0" // Temporary storage for numeric input as a string
    @State private var selectedDate = Date()
    @State private var selectedPayee: Int64 = 0
    @State private var selectedCategory: Int64 = 0

    @Binding var payees: [Payee]
    @Binding var categories: [Category]
    @Binding var accounts: [Account]
    
    // Focus state for the Amount input to control keyboard focus
    @FocusState private var isAmountFocused: Bool
    
    var body: some View {
        VStack {
            // 1. Transaction type picker (Deposit/Withdrawal/Transfer)
            HStack {
                Picker("", selection: $txn.transcode) {
                    ForEach(Transcode.allCases) { transcode in
                        Text(transcode.name).tag(transcode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle()) // Use a segmented style for the picker
                .padding(.horizontal)
                
                Spacer()
                
                Picker("Select account", selection: $txn.accountID) {
                    ForEach(accounts) { account in
                        Text(account.name).tag(account.id)
                    }
                }
                .onChange(of: selectedPayee) { newValue in
                    txn.accountID = newValue // Update the transaction with the selected account
                }
            }
            .padding(.horizontal)
            
            // 2. Unified Numeric Input for the Amount with automatic keyboard focus
            TextField("¥0", text: $amountString)
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
                .onChange(of: amountString) { newValue in
                    // Update the transaction amount in the txn object, converting from String
                    txn.transAmount = Double(newValue) ?? 0.0
                }
            
            // 3. Input field for notes
            TextField("Add Note", text: Binding(
                get: { txn.notes ?? "" }, // Safely unwrap the optional notes field
                set: { txn.notes = $0.isEmpty ? nil : $0 } // Set notes to nil if the input is empty
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
                    .onChange(of: selectedDate) { newDate in
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
            .padding(.horizontal)
            
            // 5. Horizontal stack for Payee and Category pickers
            HStack {
                // Payee picker
                Picker("Select Payee", selection: $selectedPayee) {
                    ForEach(payees) { payee in
                        Text(payee.name).tag(payee.id)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Show a menu for the payee picker
                .onChange(of: selectedPayee) { newValue in
                    txn.payeeID = newValue // Update the transaction with the selected payee
                }
                
                Spacer()

                // Category picker
                Picker("Select Category", selection: $selectedCategory) {
                    ForEach(categories) { category in
                        Text(category.name).tag(category.id)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Show a menu for the category picker
                .onChange(of: selectedCategory) { newValue in
                    txn.categID = newValue // Update the transaction with the selected category
                }
            }
            .padding(.horizontal)
            
            Spacer() // Push the contents to the top
        }
        .padding(.horizontal)
        .onAppear {
            // Initialize state variables from the txn object when the view appears
            amountString = String(format: "%.2f", txn.transAmount ?? 0.0)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            selectedDate = dateFormatter.date(from: txn.transDate) ?? Date()
            selectedPayee = txn.payeeID
        }
        .onDisappear {
            // Resign the focus when the view disappears, hiding the keyboard
            isAmountFocused = false
        }
    }
}

#Preview {
    TransactionEditView(txn: .constant(Transaction.sampleData[0]), payees: .constant(Payee.sampleData), categories: .constant(Category.sampleData), accounts: .constant(Account.sampleData))
}

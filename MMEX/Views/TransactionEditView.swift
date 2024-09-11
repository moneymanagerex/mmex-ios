//
//  TransactionEditView2.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionEditView: View {
    @Binding var txn: Transaction
    @State private var amountString: String = "0" // Temporary to store string input for amount
    @State private var selectedDate = Date()
    
    @State private var selectedPayee: Int64 = 0
    @State private var selectedCategory: Int64 = 0

    @Binding var payees: [Payee]
    @State private var categories: [Category] = []
    
    var body: some View {
        VStack {
            // Transaction type picker (Deposit/Withdrawal/Transfer)
            Picker("", selection: $txn.transcode) {
                ForEach(Transcode.allCases) { transcode in
                    Text(transcode.name).tag(transcode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Unified Numeric Input for the Amount
            TextField("¥0", text: $amountString)
                .keyboardType(.decimalPad)
                .font(.system(size: 48, weight: .bold))
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.bottom, 20)
                .onChange(of: amountString) { newValue in
                    txn.transAmount = Double(newValue) ?? 0.0 // Update the transaction object
                }
            
            // Input field for notes
            TextField("Add Note", text: Binding(
                get: { txn.notes ?? "" }, // Safely unwrap the optional notes
                set: { txn.notes = $0.isEmpty ? nil : $0 } // Set to nil if the note is empty
            ))
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .padding(.top)
            
            // Horizontal stack for date picker, status picker
            HStack {
                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    .labelsHidden() // Hide label to save space
                    .onChange(of: selectedDate) { newDate in
                        // You can format the date and store it as a string in txn.transDate
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        txn.transDate = dateFormatter.string(from: newDate)
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
            
            // 4. Payee and Category Pickers in One Row
            HStack {

                Picker("Select Payee", selection: $selectedPayee) {
                    ForEach(payees) { payee in
                        Text(payee.name).tag(payee.id)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedPayee) { newValue in
                    txn.payeeID = newValue
                }
                
                Spacer()

                Picker("Select Category", selection: $selectedCategory) {
                    ForEach(categories) { category in
                        Text(category.name).tag(category.id)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedCategory) { newValue in
                    txn.categID = newValue
                }

            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.horizontal)
        .onAppear() {
            // Initialize state variables from the txn
            amountString = String(format: "%.2f", txn.transAmount ?? 0.0 )
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            selectedDate = dateFormatter.date(from: txn.transDate) ?? Date()
        }
    }
}

#Preview {
    TransactionEditView(txn: .constant(Transaction.sampleData[0])
                        , payees: .constant(Payee.sampleData))
}

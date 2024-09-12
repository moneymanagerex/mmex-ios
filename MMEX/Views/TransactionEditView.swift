//
//  TransactionEditView2.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionEditView: View {
    @Binding var txn: Transaction
    @State private var amountString: String = "0"
    @State private var selectedDate = Date()
    @State private var selectedPayee: Int64 = 0
    @State private var selectedCategory: Int64 = 0
    
    @Binding var payees: [Payee]
    @Binding var categories: [Category]
    @Binding var accounts: [Account]
    
    @FocusState private var isAmountFocused: Bool
    
    var body: some View {
        Form {
            // Section 1: Transaction Type and Account Picker
            Section() {
                Picker("Transaction Type", selection: $txn.transcode) {
                    ForEach(Transcode.allCases) { transcode in
                        Text(transcode.name).tag(transcode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Picker("Account", selection: $txn.accountID) {
                    ForEach(accounts) { account in
                        Text(account.name).tag(account.id)
                    }
                }
            }
            
            // Section 2: Amount and Note Input
            Section() {
                // Amount input field
                TextField("¥0", text: $amountString)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 48, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .focused($isAmountFocused)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isAmountFocused = true
                        }
                    }
                    .onChange(of: amountString) { newValue in
                        txn.transAmount = Double(newValue) ?? 0.0
                    }
                
                // Smaller note input
                HStack {
                    Image(systemName: "note.text")
                        .foregroundColor(.gray)
                    TextField("Add Note", text: Binding(
                        get: { txn.notes ?? "" },
                        set: { txn.notes = $0.isEmpty ? nil : $0 }
                    ))
                    .font(.system(size: 14))
                }
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .frame(height: 40)
            }
            
            // Section 3: Date and Status Picker
            Section() {
                HStack {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                    
                    Picker("Status", selection: $txn.status) {
                        ForEach(TransactionStatus.allCases) { status in
                            Text(status.id).tag(status)
                        }
                    }
                }
            }
            
            // Section 4: Payee Picker
            Section() {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                    Picker("Select Payee", selection: $selectedPayee) {
                        ForEach(payees) { payee in
                            Text(payee.name).tag(payee.id)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            // Section 5: Category Picker
            Section() {
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundColor(.gray)
                    Picker("Select Category", selection: $selectedCategory) {
                        ForEach(categories) { category in
                            Text(category.name).tag(category.id)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .onAppear {
            amountString = String(format: "%.2f", txn.transAmount ?? 0.0)
            selectedDate = DateFormatter().date(from: txn.transDate) ?? Date()
            selectedPayee = txn.payeeID
        }
        .onDisappear {
            isAmountFocused = false
        }
    }
}

#Preview {
    TransactionEditView(txn: .constant(Transaction.sampleData[0]), payees: .constant(Payee.sampleData), categories: .constant(Category.sampleData), accounts: .constant(Account.sampleData))
}

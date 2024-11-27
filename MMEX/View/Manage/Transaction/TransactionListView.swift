//
//  CheckingListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionListView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel

    @State private var txns: [TransactionData] = []
    @State private var newTxn = TransactionData()
    @State private var isPresentingTransactionAddView = false
    @State private var selectedYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        Group {
            List($vm.txns) { $txn in
                NavigationLink(
                    destination: TransactionDetailView(
                        txn: $txn
                    )
                ) {
                    HStack {
                        // Left column: Date (truncated to day)
                        Text(formatDate(from: txn.transDate.string))
                            .frame(width: 90, alignment: .leading)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)

                        // Spacer between date and middle section
                        Spacer(minLength: 5)

                        // Middle column: Payee name and Category icon (or ID)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(getPayeeName(for: txn))
                                .font(.system(size: 16))
                                .lineLimit(1) // Prevent wrapping
                            Text("\(txn.transCode.rawValue)") // Replace with transcode name if available
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(width: 100, alignment: .leading)

                        // Spacer between middle and right section
                        Spacer()

                        // Right column: Amount
                        Text(String(format: "%.2f", txn.transAmount))
                            .frame(alignment: .trailing)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(txn.transAmount >= 0 ? .green : .red)
                    }
                }
            }

            .toolbar {
                // Year Picker
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("Year", selection: $selectedYear) {
                        ForEach((2010...Calendar.current.component(.year, from: Date())).reversed(), id: \.self) { year in
                            Text(String(format: "%d", year)).tag(year) // Correct year format
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // Show as a menu
                    .onChange(of: selectedYear) {
                        loadSelectedTransactions()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isPresentingTransactionAddView = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .accessibilityLabel("New Transaction")
                }
            }
        }

        .sheet(isPresented: $isPresentingTransactionAddView) {
            NavigationView {
                TransactionAddView(
                    newTxn: $newTxn,
                    isPresentingTransactionAddView: $isPresentingTransactionAddView
                ) { newTxn in
                    vm.addTransaction(txn: &newTxn)
                    newTxn = TransactionData()
                }
            }
        }

        .onAppear {
            log.trace("DEBUG: EnterView.load(main=\(Thread.isMainThread))")
            Task {
                await vm.loadEnterList(pref)
                if let defaultAccountId = vm.infotableList.defaultAccountId.readyValue {
                    newTxn.accountId = defaultAccountId
                }
            }
            loadSelectedTransactions()
        }
    }

    func getPayeeName(for txn: TransactionData) -> String {
        if txn.transCode == .transfer {
            if let toAccount = vm.accountList.data.readyValue?[txn.toAccountId] {
                String(format: "> \(toAccount.name)")
            } else {
                "> (unknown)"
            }
        } else {
            vm.payeeList.data.readyValue?[txn.payeeId]?.name ?? "(unknown)"
        }
    }

    // Helper function to format the date, truncating to day
    func formatDate(from isoDate: String) -> String {
        return String(isoDate.prefix(10))
/*
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // Assuming ISO-8601 format
        if let date = formatter.date(from: isoDate) {
            formatter.dateFormat = "yyyy-MM-dd" // Truncate to day
            return formatter.string(from: date)
        }
        return isoDate
*/
    }

    // Filter transactions based on selected year
    func loadSelectedTransactions() {
        let startDate = Calendar.current.date(from: DateComponents(year: selectedYear, month: 1, day: 1)) ?? Date()
        let endDate = Calendar.current.date(from: DateComponents(year: selectedYear + 1, month: 1, day: 1))?.addingTimeInterval(-1) ?? Date()
        Task {
            let data = await vm.loadTransactions(db: vm.db, for: nil, startDate: startDate, endDate: endDate)
            vm.groupTransactions(data)
        }
    }
}

#Preview {
    MMEXPreview.sampleManage { pref, vm in
        TransactionListView()
    }
}

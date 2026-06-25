//
//  TransactionListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct TransactionListView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel

    @State private var newTxn = JournalData()
    @State private var selectedYear = Calendar.current.component(.year, from: Date())

    @State private var createSheetIsPresented = false

    var body: some View {
        Group {
            List($vm.journals) { $journal in
                NavigationLink(
                    destination: TransactionDetailView(journal: $journal)
                ) {
                    HStack {
                        // Left column: Date (truncated to day)
                        Text(formatDate(from: journal.transDate.string))
                            .frame(width: 90, alignment: .leading)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)

                        // Spacer between date and middle section
                        Spacer(minLength: 5)

                        // Middle column: Payee name and Category icon (or ID)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(getPayeeName(for: journal))
                                .font(.system(size: 16))
                                .lineLimit(1) // Prevent wrapping
                            Text("\(journal.transCode.rawValue)") // Replace with transcode name if available
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(width: 100, alignment: .leading)

                        // Spacer between middle and right section
                        Spacer()

                        // Right column: Amount
                        Text(String(format: "%.2f", journal.transAmount))
                            .frame(alignment: .trailing)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(journal.transAmount >= 0 ? .green : .red)
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
                        createSheetIsPresented = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                    .accessibilityLabel("New Transaction")
                }
            }
        }

        .sheet(isPresented: $createSheetIsPresented) {
            NavigationView {
                TransactionCreateView(
                    isPresented: $createSheetIsPresented,
                    newJournal: $newTxn
                ) { newTxn in
                    _ = vm.saveJournal(&newTxn)
                    newTxn = JournalData()
                }
            }
        }

        .onAppear {
            log.trace("DEBUG: EnterView.load(main=\(Thread.isMainThread))")
            Task {
                await vm.loadTransactionList(pref)
                await vm.loadJournalList(pref)
                await vm.loadEnterList(pref)
                if let defaultAccountId = vm.infotableList.defaultAccountId.readyValue {
                    newTxn.accountId = defaultAccountId
                }
            }
            loadSelectedTransactions()
        }
    }

    func getPayeeName(for txn: JournalData) -> String {
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
            vm.loadJournals(accountId: nil, startDate: startDate, endDate: endDate)
        }
    }
}

#Preview {
    MMEXPreview.manageList { pref, vm in
        TransactionListView()
    }
}

//
//  JournalView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct JournalView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @EnvironmentObject var context: AppContext

    @StateObject private var debounce = RepositorySearchDebounce()

    @State private var typeFilter: JournalType? = nil
    let initialTypeFilter: JournalType?

    init(initialTypeFilter: JournalType? = nil) {
        self.initialTypeFilter = initialTypeFilter
        _typeFilter = State(initialValue: initialTypeFilter)
    }

    private var filteredJournals: [JournalData] {
        guard let type = typeFilter else { return vm.journals }
        return vm.journals.filter { $0.type == type }
    }

    private var groupedJournals: [String: [JournalData]] {
        vm.groupJournals(searchQuery: debounce.output, typeFilter: typeFilter)
    }

    private var sortedDays: [String] {
        groupedJournals.keys.sorted(by: >)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedDays, id: \.self) { day in
                    if let journals = groupedJournals[day] {
                        Section(
                            header: HStack {
                                Text(humanReadableDate(day))
                                    .font(.headline)
                                Spacer()
                                Text("Total: \(calculateTotal(for: journals))")
                                    .font(.subheadline)
                            }
                        ) {
                            ForEach(journals, id: \.id) { journal in
                                transactionView(journal, for: day)
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if
                        let accountOrder = vm.accountList.order.readyValue,
                        let accountData  = vm.accountList.data.readyValue
                    {
                        Picker("Select Account", selection: $context.selectedAccountId) {
                            if context.selectedAccountId.isVoid {
                                Text("Select Account").tag(DataId.void)
                            }
                            ForEach(accountOrder) { id in
                                if let account = accountData[id] {
                                    HStack{
                                        Image(systemName: account.type.symbolName)
                                            .frame(width: 5, alignment: .leading) // Adjust width as needed
                                            .font(.system(size: 16, weight: .bold)) // Customize size and weight
                                            .foregroundColor(.blue) // Customize icon style
                                        Text(account.name)
                                    }.tag(account.id)
                                }
                            }
                        }
                        .pickerStyle(MenuPickerStyle()) // Makes it appear as a dropdown
                        .onChange(of: context.selectedAccountId) {
                            Task {
                                vm.loadJournals(accountId: context.selectedAccountId)
                            }
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("All") { typeFilter = nil }
                        ForEach(JournalType.allCases, id: \.self) { type in
                            Button(type.name) { typeFilter = type }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text(typeFilter?.name ?? "All")
                                .font(.caption)
                        }
                    }
                }
            }
            .searchable(text: $debounce.input, prompt: "Search by keyword")
 //           .onChange(of: debounce.output) { _, query in
//              vm.filterJournals(by: query)
//            }
        }
        .task {
            log.debug("DEBUG: JournalView.onAppear(main=\(Thread.isMainThread))")
            await vm.loadTransactionList(pref)
            await vm.loadJournalList(pref)
            Task {
                vm.loadJournals(accountId: context.selectedAccountId)
            }
        }
    }

    func transactionView(_ txn: JournalData, for day: String) -> some View {
        NavigationLink(destination: TransactionDetailView(
            journal: Binding(
                get: {
                    self.groupedJournals[day]?.first(where: { $0.id == txn.id }) ?? txn
                },
                set: { newTxn in
                    if let index = vm.journals.firstIndex(where: { $0.id == txn.id }) {
                        vm.journals[index] = newTxn
                    }
                }
            )
        ) ) {
            HStack {
                let categoryName = vm.categoryList.data.readyValue?[txn.categId]?.name
                // Left column (Category Icon or Category Name)
                if let categoryName, let categorySymbol = pref.symbol.category2symbol[categoryName] {
                    Image(systemName: categorySymbol)
                        .frame(width: 50, alignment: .leading) // Adjust width as needed
                        .font(.system(size: 16, weight: .bold)) // Customize size and weight as needed
                        .foregroundColor(.blue) // Customize icon style
                } else {
                    Text(categoryName ?? "(unknown)") // Fallback to category name if symbol is not found
                        .frame(width: 50, alignment: .leading)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                }

                // Add a small type badge
                VStack {
                    Image(systemName: txn.type == .transaction ? "checkmark.circle" :
                            txn.type == .scheduled ? "clock.arrow.circlepath" :
                            "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                // Middle column (Payee Name & Time)
                VStack(alignment: .leading, spacing: 4) {
                    Text(getPayeeName(for: txn)) // Payee name
                        .font(.system(size: 16))
                        .lineLimit(1) // Prevent wrapping
                    Text(formatTime(txn.transDate.string)) // Show time in hh:mm a
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .frame(width: 100, alignment: .leading) // Widen middle column, ensuring enough space

                Spacer() // To push the amount to the right side

                if
                    let currencyId   = vm.accountList.data.readyValue?[txn.accountId]?.currencyId,
                    let currencyInfo = vm.currencyList.info.readyValue?[currencyId]
                {
                    // Right column (Transaction Amount)
                    VStack {
                        // amount in account currency
                        Text(txn.transAmount.formatted(by: currencyInfo.formatter))
                        .frame(alignment: .trailing) // Ensure it's aligned to the right
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(txn.transCode == TransactionType.deposit ? .green : .red) // Positive/negative amount color
                        // amount in base currency
                        if let baseCurrencyId = vm.infotableList.baseCurrencyId.readyValue,
                           baseCurrencyId != currencyId
                        {
                            Text((txn.transAmount * currencyInfo.baseConvRate)
                                .formatted(by: vm.currencyList.info.readyValue?[baseCurrencyId]?.formatter)
                            )
                            .frame(alignment: .trailing) // Ensure it's aligned to the right
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(txn.transCode == TransactionType.deposit ? .green : .red) // Positive/negative amount color
                        }
                    }
                } else {
                    // Right column (Transaction Amount)
                    Text(String(format: "%.2f", txn.transAmount))
                        .frame(alignment: .trailing) // Ensure it's aligned to the right
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(txn.transCode == TransactionType.deposit ? .green : .red) // Positive/negative amount color
                }
            }
        }
    }

    func getPayeeName(for txn: JournalData) -> String {
        // Find the payee with the given ID
        if txn.transCode == .transfer {
            if self.context.selectedAccountId == txn.accountId {
                if let toAccount = vm.accountList.data.readyValue?[txn.toAccountId] {
                    return String(format: "> \(toAccount.name)")
                }
            } else {
                if let fromAccount = vm.accountList.data.readyValue?[txn.accountId] {
                    return String(format: "< \(fromAccount.name)")
                }
            }
        } else if let payee = vm.payeeList.data.readyValue?[txn.payeeId] {
            return payee.name
        }
        return "(uknown)"
    }

    func calculateTotal(for journals: [JournalData]) -> String {
        let totalAmount = journals.reduce(0.0) { $0 + $1.actual }
        let account = vm.accountList.data.readyValue?[context.selectedAccountId]
        let formatter = vm.currencyList.info.readyValue?[account?.currencyId ?? .void]?.formatter
        return totalAmount.formatted(by: formatter)
    }

    func humanReadableDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            if Calendar.current.isDateInToday(date) {
                return "Today"
            } else if Calendar.current.isDateInYesterday(date) {
                return "Yesterday"
            } else {
                formatter.dateStyle = .medium
                return formatter.string(from: date)
            }
        }
        return dateString
    }

    func formatTime(_ dateTimeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // Assuming the stored format is ISO-8601
        if let dateTime = formatter.date(from: dateTimeString) {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: dateTime)
        }
        return dateTimeString // Fallback if parsing fails
    }
}

#Preview {
    MMEXPreview.tab("Journal") { pref, vm in
        JournalView()
    }
}

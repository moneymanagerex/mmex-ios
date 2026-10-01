//
//  OverviewView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/22.
//

import SwiftUI

struct OverviewView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @EnvironmentObject var context: AppContext
    @StateObject private var viewModel = OverviewViewModel()
    
    @State private var selectedFilter: TransactionType? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                OverviewHeader(formatter: displayFormatter, accountBalances: viewModel.accountBalances)
                
                FinancialSummaryCard(
                    netWorth: viewModel.netWorth,
                    previousNetWorth: viewModel.previousNetWorth,
                    netWorthChange: viewModel.netWorthChange,
                    income: viewModel.income,
                    expense: viewModel.expense,
                    incomeChange: viewModel.incomeChange,
                    expenseChange: viewModel.expenseChange,
                    selectedFilter: $selectedFilter,
                    formatter: displayFormatter,
                    transactions: viewModel.transactions
                )
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Trend")
                            .font(.headline)
                        Spacer()
                        NavigationLink("Details") {
                            InsightsView()
                        }
                        .font(.subheadline)
                    }
                    .padding(.horizontal)
                    
                    IncomeExpenseView(stats: viewModel.transactions)
                        .frame(height: 150)
                        .padding(.horizontal, 4)
                    
                    InsightsCaptionView(transactions: viewModel.transactions)
                        .padding(.horizontal)
                }
                
                Divider()
                
                ScheduledOverviewView()
                    .padding(.horizontal, 8)

                Divider()

                RecentTransactionsView(
                    journals: viewModel.transactions.asJournals(),
                    selectedFilter: $selectedFilter,
                    showAccountLabel: context.isAllAccounts,
                    formatter: displayFormatter
                )
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await vm.loadAccountList(pref)
                await vm.loadPayeeList(pref)
                await vm.loadScheduledList(pref)
                viewModel.refresh(db: vm.db, accounts: vm.accountList.data.readyValue ?? [:], context: context)
            }
        }
        .onChange(of: context.selectedAccountId) { _, _ in
            viewModel.refresh(db: vm.db, accounts: vm.accountList.data.readyValue ?? [:], context: context)
        }
        .onChange(of: context.dateRangePreset) { _, _ in
            viewModel.refresh(db: vm.db, accounts: vm.accountList.data.readyValue ?? [:], context: context)
        }
        .onChange(of: context.customStartDate) { _, _ in
            viewModel.refresh(db: vm.db, accounts: vm.accountList.data.readyValue ?? [:], context: context)
        }
        .onChange(of: context.customEndDate) { _, _ in
            viewModel.refresh(db: vm.db, accounts: vm.accountList.data.readyValue ?? [:], context: context)
        }
        .onChange(of: vm.infotableList.baseCurrencyId.value) {_, _ in
            viewModel.refresh(db: vm.db, accounts: vm.accountList.data.readyValue ?? [:], context: context)
        }
    }
}

// OverviewView.swift
extension OverviewView {
    var displayFormatter: CurrencyFormatter? {
        let currencyId: DataId
        if context.selectedAccountId.isVoid {
            // All Accounts → Base Currency
            guard let baseId = vm.infotableList.baseCurrencyId.readyValue else { return nil }
            currencyId = baseId
        } else {
            //
            guard let account = vm.accountList.data.readyValue?[context.selectedAccountId] else { return nil }
            currencyId = account.currencyId
        }
        return vm.currencyList.info.readyValue?[currencyId]?.formatter
    }
}

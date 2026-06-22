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
    
    @State private var selectedFilter: TransactionType? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    OverviewHeader(formatter: displayFormatter)
                    
                    FinancialSummaryCard(
                        netWorth: vm.overviewNetWorth,
                        previousNetWorth: vm.overviewPreviousNetWorth,
                        netWorthChange: vm.overviewNetWorthChange,
                        income: vm.overviewIncome,
                        expense: vm.overviewExpense,
                        incomeChange: vm.overviewIncomeChange,
                        expenseChange: vm.overviewExpenseChange,
                        selectedFilter: $selectedFilter,
                        formatter: displayFormatter
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
                        
                        IncomeExpenseView(stats: $vm.overviewTransactions)
                            .frame(height: 150)
                            .padding(.horizontal, 4)
                        
                        InsightsCaptionView(transactions: vm.overviewTransactions)
                            .padding(.horizontal)
                    }
                    
                    Divider()
                    
                    ScheduledOverviewView()
                        .padding(.horizontal, 8)

                    Divider()

                    RecentTransactionsView(
                        transactions: vm.overviewTransactions,
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
                    vm.refreshOverview()
                }
            }
            .onChange(of: context.selectedAccountId) { _, _ in
                vm.refreshOverview()
            }
            .onChange(of: context.dateRangePreset) { _, _ in
                vm.refreshOverview()
            }
            .onChange(of: context.customStartDate) { _, _ in
                vm.refreshOverview()
            }
            .onChange(of: context.customEndDate) { _, _ in
                vm.refreshOverview()
            }
            .onChange(of: vm.infotableList.baseCurrencyId.value) {_, _ in
                vm.refreshOverview()
            }
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

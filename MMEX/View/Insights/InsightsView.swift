//
//  InsightsView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/11.
//

import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @EnvironmentObject var context: AppContext
    @StateObject private var viewModel = InsightsViewModel()

    @State var statusChoice: InsightsAccountMode = .balance
    @State var accountBalanceIsExpanded = true
    @State var budgetIsExpanded = true
    @State var forecastIsExpanded = true
    @State var incomeExpenseIsExpanded = true

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Section(header: HStack {
                    Button(action: { accountBalanceIsExpanded.toggle() }) {
                        pref.theme.group.view(
                            nameView: { Text(statusChoice.sectionTitle) },
                            isExpanded: accountBalanceIsExpanded
                        )
                    }
                }) { if accountBalanceIsExpanded {
                    InsightsAccountView(statusChoice: $statusChoice)
                } }

                Section(header: HStack {
                    Button(action: { budgetIsExpanded.toggle() }) {
                        pref.theme.group.view(
                            nameView: { Text("Budget vs Actual") },
                            isExpanded: budgetIsExpanded
                        )
                    }
                }) { if budgetIsExpanded {
                    BudgetProgressSection(formatter: displayFormatter)
                } }

                Section(header: HStack {
                    Button(action: { forecastIsExpanded.toggle() }) {
                        pref.theme.group.view(
                            nameView: { Text("Cash Flow Forecast") },
                            isExpanded: forecastIsExpanded
                        )
                    }
                }) { if forecastIsExpanded {
                    CashFlowForecastSection(formatter: displayFormatter)
                } }

                Section(header: HStack {
                    Button(action: { incomeExpenseIsExpanded.toggle() }) {
                        pref.theme.group.view(
                            nameView: { Text("Income vs Expense Over Time") },
                            isExpanded: incomeExpenseIsExpanded
                        )
                    }
                }) { if incomeExpenseIsExpanded {
                    HStack {
                        DatePicker("Start Date", selection: Binding(
                            get: { Calendar.current.startOfDay(for: viewModel.startDate) },
                            set: { viewModel.startDate = Calendar.current.startOfDay(for: $0) }
                        ), displayedComponents: .date).labelsHidden().datePickerStyle(.compact)
                        Spacer()
                        DatePicker("End Date", selection: Binding(
                            get: { Calendar.current.startOfDay(for: viewModel.endDate) },
                            set: { viewModel.endDate = Calendar.current.startOfDay(for: $0) }
                        ), displayedComponents: .date).labelsHidden().datePickerStyle(.compact)
                    }
                    .padding()
                    .background(Color(.systemGray6)).cornerRadius(10).shadow(radius: 2)

                    IncomeExpenseView(stats: viewModel.recentStats)

                    InsightsCaptionView(
                        transactions: viewModel.recentStats,
                        startDate: viewModel.startDate,
                        endDate: viewModel.endDate
                    )
                    .padding(.horizontal)
                } }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .task {
            log.debug("DEBUG: InsightsView.task(main=\(Thread.isMainThread))")
            await vm.loadInsightsList(pref)
            syncDatesFromContext()
            viewModel.load(
                db: vm.db,
                baseCurrencyId: vm.infotableList.baseCurrencyId.readyValue,
                currencyInfo: vm.currencyList.info.readyValue
            )
            viewModel.loadBudget(from: vm)
            viewModel.loadForecast(from: vm, days: 30)
        }
        .onChange(of: context.effectiveStartDate) { _, _ in syncDatesFromContext() }
        .onChange(of: context.effectiveEndDate)   { _, _ in syncDatesFromContext() }
        .environmentObject(viewModel)
    }

    private func syncDatesFromContext() {
        guard let s = context.effectiveStartDate, let e = context.effectiveEndDate else { return }
        viewModel.setDateRange(start: s, end: e)
    }

    private var displayFormatter: CurrencyFormatter? {
        guard let baseId = vm.infotableList.baseCurrencyId.readyValue else { return nil }
        return vm.currencyList.info.readyValue?[baseId]?.formatter
    }
}

#Preview {
    MMEXPreview.tab("Insights") { pref, vm in
        InsightsView()
    }
}

extension MMEXPreview {
    @ViewBuilder
    static func insights<Content: View>(
        _ sectionTitle: String,
        @ViewBuilder content: @escaping (_ pref: Preference, _ vm: ViewModel) -> Content
    ) -> some View {
        MMEXPreview.tab("Insights") { pref, vm in
            ScrollView {
                VStack(spacing: 20) {
                    Section(header: HStack {
                        pref.theme.group.view(
                            nameView: { Text(sectionTitle) },
                            isExpanded: true
                        )
                    } ) {
                        content(pref, vm)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .environmentObject(InsightsViewModel())
        }
    }
}

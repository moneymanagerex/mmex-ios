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
                    quickRanges
                    HStack {
                        DatePicker("From", selection: Binding(
                            get: { Calendar.current.startOfDay(for: viewModel.startDate) },
                            set: { viewModel.startDate = min(Calendar.current.startOfDay(for: $0), viewModel.endDate) }
                        ), displayedComponents: .date).datePickerStyle(.compact)
                        Spacer()
                        DatePicker("To", selection: Binding(
                            get: { Calendar.current.startOfDay(for: viewModel.endDate) },
                            set: { viewModel.endDate = max(Calendar.current.startOfDay(for: $0), viewModel.startDate) }
                        ), displayedComponents: .date).datePickerStyle(.compact)
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
            viewModel.loadForecast(from: vm, days: 30, accountId: context.selectedAccountId)
        }
        .onChange(of: context.effectiveStartDate) { _, _ in syncDatesFromContext() }
        .onChange(of: context.effectiveEndDate)   { _, _ in syncDatesFromContext() }
        .environmentObject(viewModel)
    }

    private func syncDatesFromContext() {
        guard let s = context.effectiveStartDate, let e = context.effectiveEndDate else { return }
        viewModel.setDateRange(start: s, end: e)
    }

    private var quickRanges: some View {
        HStack(spacing: 8) {
            quickRangeButton("30 days", days: 30)
            quickRangeButton("90 days", days: 90)
            quickRangeButton("12 months", days: 365)
            Spacer(minLength: 0)
        }
    }

    private func quickRangeButton(_ title: String, days: Int) -> some View {
        Button(title) {
            let calendar = Calendar.current
            let end = calendar.startOfDay(for: Date())
            let start = calendar.date(byAdding: .day, value: -days + 1, to: end) ?? end
            viewModel.setDateRange(start: start, end: end)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.accentColor.opacity(0.1), in: Capsule())
        .buttonStyle(.plain)
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

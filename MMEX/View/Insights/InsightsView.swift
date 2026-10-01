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
    @StateObject private var viewModel = InsightsViewModel()

    @State var statusChoice: Int = 0
    @State var accountBalanceIsExpanded = true
    @State var accountIncomeIsExpanded = true
    @State var incomeExpenseIsExpanded = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Section(header: HStack {
                    Button(action: { accountBalanceIsExpanded.toggle() }) {
                        pref.theme.group.view(
                            nameView: { Text(InsightsAccountView.statusChoices[statusChoice].0) },
                            isExpanded: accountBalanceIsExpanded
                        )
                    }
                } ) { if accountBalanceIsExpanded {
                    InsightsAccountView(
                        statusChoice: $statusChoice
                    )
                } }
                
                Section(header: HStack {
                    Button(action: { accountIncomeIsExpanded.toggle() }) {
                        pref.theme.group.view(
                            nameView: { Text("Account Income Summary") },
                            isExpanded: accountIncomeIsExpanded
                        )
                    }
                } ) { if accountIncomeIsExpanded {
                    InsightsSummaryView(
                        stats: viewModel.stats,
                        accountNames: vm.accountList.data.readyValue?.mapValues(\.name) ?? [:]
                    )
                } }
                
                Section(header: HStack {
                    Button(action: { incomeExpenseIsExpanded.toggle() }) {
                        pref.theme.group.view(
                            nameView: { Text("Income vs Expense Over Time") },
                            isExpanded: incomeExpenseIsExpanded
                        )
                    }
                } ) { if incomeExpenseIsExpanded {
                    // Date Range Filters
                    HStack {
                        DatePicker("Start Date", selection:  Binding(
                            get: {
                                Calendar.current.startOfDay(for: viewModel.startDate)
                            },
                            set: { newValue in
                                viewModel.startDate = Calendar.current.startOfDay(for: newValue)
                            }
                        ), displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                        
                        Spacer()
                        
                        DatePicker("End Date", selection: Binding(
                            get: {
                                Calendar.current.startOfDay(for: viewModel.endDate)
                            },
                            set: { newValue in
                                viewModel.endDate = Calendar.current.startOfDay(for: newValue)
                            }
                        ), displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    
                    IncomeExpenseView(stats: viewModel.recentStats)
                } }
                
                // Placeholder for Future Sections
                Section {
                    VStack {
                        Text("More Insights Coming Soon...")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                } header: {
                    Text("Upcoming Features")
                        .font(.headline)
                        .padding(.horizontal)
                }
                
            }
            .padding(.horizontal)
            .padding(.top, 10) // Reduce the top padding for less space at the top
        }

        //.navigationBarTitleDisplayMode(.inline) // Ensure title is inline to reduce top space

        .task {
            log.debug("DEBUG: InsightsView.onAppear(main=\(Thread.isMainThread))")
            await vm.loadInsightsList(pref)
            viewModel.load(db: vm.db)
        }
        .environmentObject(viewModel)
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

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
                        stats: $vm.stats
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
                        DatePicker("Start Date", selection: $vm.startDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                        
                        Spacer()
                        
                        DatePicker("End Date", selection: $vm.endDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    
                    IncomeExpenseView(stats: $vm.recentStats)
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
        .navigationBarTitleDisplayMode(.inline) // Ensure title is inline to reduce top space
        .task {
            log.debug("DEBUG: InsightsView.onAppear(main=\(Thread.isMainThread))")
            await vm.loadInsightsList(pref)
            vm.loadInsights()
        }
    }
}

#Preview {
    let pref = Preference()
    let vm = ViewModel.sampleData
    NavigationView {
        InsightsView(
        )
        .navigationBarTitle("Insights", displayMode: .inline)
    }
    .environmentObject(pref)
    .environmentObject(vm)
}

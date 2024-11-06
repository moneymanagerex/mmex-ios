//
//  InsightsView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/11.
//

import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel
    @ObservedObject var viewModel: InsightsViewModel
    @State var statusChoice: Int = 0
    @State var accountBalanceIsExpanded = true
    @State var accountIncomeIsExpanded = true
    @State var incomeExpenseIsExpanded = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Section(header: HStack {
                    Button(action: { accountBalanceIsExpanded.toggle() }) {
                        env.theme.group.view(
                            name: { Text(InsightsAccountView.statusChoices[statusChoice].0) },
                            isExpanded: accountBalanceIsExpanded
                        )
                    }
                } ) { if accountBalanceIsExpanded {
                    InsightsAccountView(
                        vm: vm,
                        viewModel: viewModel,
                        statusChoice: $statusChoice
                    )
                } }
                
                Section(header: HStack {
                    Button(action: { accountIncomeIsExpanded.toggle() }) {
                        env.theme.group.view(
                            name: { Text("Account Income Summary") },
                            isExpanded: accountIncomeIsExpanded
                        )
                    }
                } ) { if accountIncomeIsExpanded {
                    InsightsSummaryView(stats: $viewModel.stats)
                } }
                
                Section(header: HStack {
                    Button(action: { incomeExpenseIsExpanded.toggle() }) {
                        env.theme.group.view(
                            name: { Text("Income vs Expense Over Time") },
                            isExpanded: incomeExpenseIsExpanded
                        )
                    }
                } ) { if incomeExpenseIsExpanded {
                    // Date Range Filters
                    HStack {
                        DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                        
                        Spacer()
                        
                        DatePicker("End Date", selection: $viewModel.endDate, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    
                    IncomeExpenseView(stats: $viewModel.recentStats)
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
    }
}

#Preview {
    let env = EnvironmentManager.sampleData
    InsightsView(
        vm: ViewModel(env: env),
        viewModel: InsightsViewModel(env: env)
    )
    .environmentObject(env)
}

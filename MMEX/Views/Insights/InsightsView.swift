//
//  InsightsView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/11.
//

import SwiftUI
import Charts

struct InsightsView: View {
    @ObservedObject var viewModel: InsightsViewModel
    @State var statusChoice: Int = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Section {
                        InsightsAccountView(
                            baseCurrency: $viewModel.baseCurrency,
                            accountInfo: $viewModel.accountInfo,
                            statusChoice: $statusChoice
                        )
                    } header: {
                        Text(InsightsAccountView.statusChoices[statusChoice].0)
                            .font(.headline)
                            .padding(.horizontal)
                    }

                    Section {
                        InsightsSummaryView(stats: $viewModel.stats)
                    } header: {
                        Text("Account Income Summary")
                            .font(.headline)
                            .padding(.horizontal)
                    }
                    
                    // Date Range Filters Section
                    Section {
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
                    }

                    Section {
                        IncomeExpenseView(stats: $viewModel.recentStats)
                    } header: {
                        Text("Income vs Expense Over Time")
                            .font(.headline)
                            .padding(.horizontal)
                    }
                    
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
}

#Preview {
    InsightsView(viewModel: InsightsViewModel(dataManager: DataManager()))
}

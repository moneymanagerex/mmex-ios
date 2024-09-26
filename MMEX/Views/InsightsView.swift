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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
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

                    // Transactions Over Time Chart Section
                    Section {
                        Chart(viewModel.stats) {
                            BarMark(
                                x: .value("Day", $0.day),
                                y: .value("Amount", $0.transAmount)
                            )
                            .foregroundStyle(by: .value("Status", $0.status.fullName))
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    } header: {
                        Text("Transactions Over Time")
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

//
//  IncomeAndExpense.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/29.
//

import SwiftUI
import Charts

struct IncomeExpenseView: View {
    @Binding var stats: [TransactionData]

    var body: some View {
        Chart() {
            ForEach(stats) { stat in
                Plot {
                    BarMark(
                        x: .value("Day", stat.day),
                        y: .value("Amount", stat.income)
                    )
                    // .foregroundStyle(by: .value("Status", $0.status.fullName))
                    .foregroundStyle(.green)
                }
                .accessibilityLabel("income")
                .accessibilityValue("\(stat.income)")
            }

            ForEach(stats) { stat in
                Plot {
                    BarMark(
                        x: .value("Day", stat.day),
                        y: .value("Amount", 0 - stat.expenses)
                    )
                    // .foregroundStyle(by: .value("Status", $0.status.fullName))
                    .foregroundStyle(.purple)
                }
                .accessibilityLabel("expenses")
                .accessibilityValue("\(stat.expenses)")
            }
        }
        .chartYAxis {
            AxisMarks(preset: .automatic, position: .leading)
        }
        .frame(height: 300)
        .chartYAxis(.automatic)
        .chartXAxis(.automatic)
        .padding(.horizontal)
    }
}

#Preview {
    IncomeExpenseView(stats: .constant(TransactionData.sampleData))
}

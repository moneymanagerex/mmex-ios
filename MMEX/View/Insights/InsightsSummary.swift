//
//  InsightsSummary.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/29.
//

import SwiftUI
import Charts

struct InsightsSummaryView: View {
    @EnvironmentObject var vm: ViewModel
    @Binding var stats: [TransactionData]

    var body: some View {
        Chart(stats) {
            BarMark(
                x: .value("Amount", $0.income),
                y: .value("Account", vm.accountList.data.readyValue?[$0.accountId]?.name ?? "#\($0.accountId.value)")
            )
            .foregroundStyle(by: .value("Status", $0.status.fullName))
        }
        .chartXAxis (.automatic)
        .chartYAxis (.automatic)
        .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
        .frame(idealHeight: 300)
    }
}

#Preview {
    let pref = Preference()
    let vm = ViewModel.sampleData
    NavigationStack {
        ScrollView {
            InsightsSummaryView(
                stats: .constant(TransactionData.sampleData)
            )
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    .environmentObject(pref)
    .environmentObject(vm)
}

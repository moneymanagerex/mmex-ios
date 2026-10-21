//
//  InsightsAccountView.swift
//  MMEX
//
//  Created 2024-09-29 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

// MARK: - Mode

enum InsightsAccountMode: Int, CaseIterable, Identifiable {
    case balance = 0
    case reconciledBalance
    case flowNone
    case flowDuplicate
    case flowFollowUp
    case flowVoid

    var id: Int { rawValue }

    var sectionTitle: String {
        switch self {
        case .balance, .reconciledBalance: return "Account Balance"
        case .flowNone, .flowDuplicate, .flowFollowUp, .flowVoid: return "Account Flow"
        }
    }

    var metricTitle: String {
        switch self {
        case .balance:           return "Balance"
        case .reconciledBalance: return "Reconciled Balance"
        case .flowNone:          return "Status: (none)"
        case .flowDuplicate:     return "Status: Duplicate"
        case .flowFollowUp:      return "Status: Follow up"
        case .flowVoid:          return "Status: Void"
        }
    }

    var isBalanceMode: Bool {
        switch self {
        case .balance, .reconciledBalance: return true
        default: return false
        }
    }

    /// 该账户在本模式下应展示的数值。
    /// - `.balance` / `.reconciledBalance`：始终返回（含初始余额），flow 缺失按 0 处理
    /// - `.flow*`：flow 缺失按 0 处理（即"无该状态交易"）
    func value(for account: AccountData, flow: AccountFlowByStatus?) -> Double {
        switch self {
        case .balance:
            return (flow?.diffTotal ?? 0) + account.initialBal
        case .reconciledBalance:
            return (flow?.diffReconciled ?? 0) + account.initialBal
        case .flowNone:
            return flow?[.none]?.diff ?? 0
        case .flowDuplicate:
            return flow?[.duplicate]?.diff ?? 0
        case .flowFollowUp:
            return flow?[.followUp]?.diff ?? 0
        case .flowVoid:
            return flow?[.void]?.diff ?? 0
        }
    }
}

// MARK: - View

struct InsightsAccountView: View {
    @EnvironmentObject var vm: ViewModel
    @EnvironmentObject var viewModel: InsightsViewModel

    @Binding var statusChoice: InsightsAccountMode
    @State private var expandedSections: [AccountType: Bool] = [:]

    static let typeOrder: [AccountType] = [
        .checking, .creditCard, .cash, .loan, .term, .asset, .investment
    ]

    private var baseFormatter: CurrencyFormatter? {
        guard let baseId = viewModel.baseCurrency?.id else { return nil }
        return vm.currencyList.info.readyValue?[baseId]?.formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            pickerRow
            if statusChoice.isBalanceMode { totalRow }
            if viewModel.flow.dataByType.isEmpty {
                emptyRow
            } else {
                sections
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }

    // MARK: - Subviews

    private var pickerRow: some View {
        HStack {
            Spacer()
            Picker("Status Choice", selection: $statusChoice) {
                ForEach(InsightsAccountMode.allCases) { mode in
                    Text(mode.metricTitle).tag(mode)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var totalRow: some View {
        HStack {
            Text("Total").font(.subheadline)
            Spacer(minLength: 10)
            Text(totalBalance.formatted(by: baseFormatter))
                .font(.subheadline)
        }
    }

    private var emptyRow: some View {
        HStack {
            Image(systemName: "tray").foregroundColor(.secondary)
            Text("No open accounts to display.")
                .font(.caption).foregroundColor(.secondary)
            Spacer()
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var sections: some View {
        ForEach(Self.typeOrder) { accountType in
            if let accounts = viewModel.flow.dataByType[accountType], !accounts.isEmpty {
                section(for: accountType, accounts: accounts)
            }
        }
    }

    @ViewBuilder
    private func section(for accountType: AccountType, accounts: [AccountData]) -> some View {
        let isExpanded = expandedSections[accountType] ?? true
        VStack(alignment: .leading, spacing: 6) {
            Button {
                expandedSections[accountType] = !isExpanded
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: accountType.symbolName)
                        .frame(width: 20, alignment: .leading)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                    Text(accountType.rawValue)
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 6) {
                    ForEach(accounts) { account in
                        accountRow(account)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }

    private func accountRow(_ account: AccountData) -> some View {
        let formatter = vm.currencyList.info.readyValue?[account.currencyId]?.formatter
        let value = statusChoice.value(
            for: account,
            flow: viewModel.flow.flowUntilToday[account.id]
        )
        return HStack {
            Text(account.name).font(.subheadline)
            Spacer(minLength: 10)
            Text(value.formatted(by: formatter)).font(.subheadline)
        }
    }

    // MARK: - Helpers

    private var totalBalance: Double {
        var total: Double = 0
        for type in Self.typeOrder {
            guard let accounts = viewModel.flow.dataByType[type] else { continue }
            for account in accounts {
                let value = statusChoice.value(
                    for: account,
                    flow: viewModel.flow.flowUntilToday[account.id]
                )
                let rate = vm.currencyList.info.readyValue?[account.currencyId]?.baseConvRate ?? 1.0
                total += value * rate
            }
        }
        return total
    }
}

#Preview {
    struct InsightsAccountPreview: View {
        @State var statusChoice: InsightsAccountMode = .balance

        var body: some View {
            MMEXPreview.insights(statusChoice.sectionTitle) { pref, vm in
                InsightsAccountView(statusChoice: $statusChoice)
            }
        }
    }
    return InsightsAccountPreview()
}

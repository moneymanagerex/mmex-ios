//
//  InsightsAccountView.swift
//  MMEX
//
//  Created 2024-09-29 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct InsightsAccountView: View {
    @EnvironmentObject var vm: ViewModel

    @Binding var statusChoice: Int
    @State private var expandedSections: [AccountType: Bool] = [:]

    static let typeOrder: [AccountType] = [ .checking, .creditCard, .cash, .loan, .term, .asset, .investment ]
    static let statusChoices = [
        ("Account Balance", "Balance"),
        ("Account Balance", "Reconciled Balance"),
        ("Account Flow", "Status: (none)"),
        ("Account Flow", "Status: Duplicate"),
        ("Account Flow", "Status: Follow up"),
        ("Account Flow", "Status: Void")
    ]

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Picker("Status Choice", selection: $statusChoice) {
                    ForEach(0..<Self.statusChoices.count, id: \.self) { choice in
                        Text(Self.statusChoices[choice].1)
                            .tag(choice)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Makes it appear as a dropdown
            }

            if Self.statusChoices[self.statusChoice].0 == "Account Balance" {
                HStack {
                    Text("Total")
                        .font(.subheadline)
                    
                    Spacer(minLength: 10)

                    let totalBalance: Double = {
                        var total: Double = 0.0
                        for type in Self.typeOrder {
                            guard let accounts = vm.flow.dataByType[type] else { continue }
                            for account in accounts {
                                let flowByStatus = vm.flow.flowUntilToday[account.id]
                                let value: Double = switch Self.statusChoices[statusChoice].1 {
                                case "Balance"            : (flowByStatus?.diffTotal         ?? 0.0) + account.initialBal
                                case "Reconciled Balance" : (flowByStatus?.diffReconciled    ?? 0.0) + account.initialBal
                                default: 0.0
                                }
                                let baseConvRate = vm.currencyList.info.readyValue?[account.currencyId]?.baseConvRate ?? 1.0
                                total = total + value * baseConvRate
                            }
                        }
                        return total
                    } ()

                    Text(totalBalance.formatted(
                        by: vm.currencyList.info.readyValue?[vm.baseCurrency?.id ?? .void]?.formatter
                    ))
                    .font(.subheadline)
                }
                .padding(.horizontal, 8)
            }

            ForEach(Self.typeOrder) { accountType in
                if let accounts = vm.flow.dataByType[accountType] {
                    Spacer(minLength: 8)
                    Section(
                        header: HStack {
                            Button(action: {
                                // Toggle expanded/collapsed state
                                expandedSections[accountType]?.toggle()
                            }) {
                                HStack {
                                    Image(systemName: accountType.symbolName)
                                        .frame(width: 5, alignment: .leading) // Adjust width as needed
                                        .font(.system(size: 16, weight: .bold)) // Customize size and weight
                                        .foregroundColor(.blue) // Customize icon style
                                    Text(accountType.rawValue)
                                        .font(.subheadline)
                                        .padding(.leading)
                                    
                                    Spacer(minLength: 10)
                                    
                                    // Expand or collapse indicator
                                    Image(systemName: expandedSections[accountType] == true ? "chevron.down" : "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    ) {
                        // Show account list based on expandedSections state
                        if expandedSections[accountType] == true {
                            VStack(spacing: 8) {
                                Spacer(minLength: 2)
                                ForEach(accounts) { account in
                                    HStack {
                                        Text(account.name)
                                            .font(.subheadline)
                                        
                                        Spacer(minLength: 10)
                                        
                                        let flowByStatus = vm.flow.flowUntilToday[account.id]
                                        let value: Double? = switch Self.statusChoices[statusChoice].1 {
                                        case "Balance"            : (flowByStatus?.diffTotal         ?? 0.0) + account.initialBal
                                        case "Reconciled Balance" : (flowByStatus?.diffReconciled    ?? 0.0) + account.initialBal
                                        case "Status: (none)"     : flowByStatus?[.none]?.diff ?? 0.0
                                        case "Status: Duplicate"  : flowByStatus?[.duplicate]?.diff ?? 0.0
                                        case "Status: Follow up"  : flowByStatus?[.followUp]?.diff ?? 0.0
                                        case "Status: Void"       : flowByStatus?[.void]?.diff ?? 0.0
                                        default                   : nil
                                        }
                                        if let value {
                                            Text(value.formatted(
                                                by: vm.currencyList.info.readyValue?[account.currencyId]?.formatter
                                            ))
                                            .font(.subheadline)
                                        }
                                    }
                                    //.padding(.horizontal)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.bottom, 8)
        .background(Color(.systemGray5))
        .cornerRadius(8)

        .onAppear {
            for accountType in Self.typeOrder {
                expandedSections[accountType] = true
            }
        }
    }
}

#Preview {
    struct InsightsAccountPreview: View {
        @State var statusChoice: Int = 0
        var sectionTitle: String { InsightsAccountView.statusChoices[statusChoice].0 }

        var body: some View {
            MMEXPreview.insights(sectionTitle) { pref, vm in
                InsightsAccountView(
                    statusChoice: $statusChoice
                )
            }
        }
    }

    return InsightsAccountPreview()
}

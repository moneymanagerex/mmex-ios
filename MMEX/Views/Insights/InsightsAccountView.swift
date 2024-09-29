//
//  Summary.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/29.
//

import SwiftUI

struct InsightsAccountInfo {
    var dataByType: [AccountType: [AccountData]] = [:]
    var today: String = ""
    var flowUntilToday: [Int64: AccountFlowByStatus] = [:]
    var flowAfterToday: [Int64: AccountFlowByStatus] = [:]
}

struct InsightsAccountView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var accountInfo: InsightsAccountInfo
    @Binding var statusChoice: Int
    @State private var expandedSections: [AccountType: Bool] = [:]

    static let typeOrder: [AccountType] = [ .checking, .creditCard, .cash, .loan, .term, .asset, .shares ]
    static let statusChoices = [
        ("Account Balance", "Reconciled Balance"),
        ("Account Balance", "Total Balance"),
        ("Account Flow", "None"),
        ("Account Flow", "Duplicate"),
        ("Account Flow", "Follow up"),
        ("Account Flow", "Void")
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

            ForEach(Self.typeOrder) { accountType in
                if let accounts = accountInfo.dataByType[accountType] {
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
                            ForEach(accounts) { account in
                                HStack {
                                    Text(account.name)
                                        .font(.subheadline)
                                    
                                    Spacer(minLength: 10)
                                    
                                    let flowByStatus = accountInfo.flowUntilToday[account.id]
                                    let value: Double = switch Self.statusChoices[statusChoice].1 {
                                    case "Reconciled Balance" : (flowByStatus?.diffReconciled    ?? 0.0) + account.initialBal
                                    case "Total Balance"      : (flowByStatus?.diffTotal         ?? 0.0) + account.initialBal
                                    case "None"               : (flowByStatus?[.none]?.diff      ?? 0.0)
                                    case "Duplicate"          : (flowByStatus?[.duplicate]?.diff ?? 0.0)
                                    case "Follow up"          : (flowByStatus?[.followUp]?.diff  ?? 0.0)
                                    case "Void"               : (flowByStatus?[.void]?.diff      ?? 0.0)
                                    default                   : 0.0
                                    }
                                    if let currency = dataManager.currencyFormat[account.currencyId] {
                                        Text(currency.format(amount: value))
                                            .font(.subheadline)
                                    } else {
                                        Text(String(format: "%.2f", value))
                                            .font(.subheadline)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            for accountType in Self.typeOrder {
                expandedSections[accountType] = true
            }
        }
    }
}

#Preview {
    //InsightsAccountView(stats: .constant(TransactionData.sampleData))
}

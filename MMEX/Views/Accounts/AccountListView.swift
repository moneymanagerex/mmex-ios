//
//  AccountListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//
import SwiftUI

struct AccountListView: View {
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment

    @State private var allCurrencyName: [(Int64, String)] = [] // sorted by name
    @State private var allAccountDataByType: [AccountType: [AccountData]] = [:] // sorted by name
    @State private var newAccount = emptyAccount
    @State private var isPresentingAccountAddView = false
    @State private var expandedSections: [AccountType: Bool] = [:] // Tracks the expanded/collapsed state
    static let emptyAccount = AccountData(
        status: AccountStatus.open
    )
    
    static let typeOrder: [AccountType] = [ .checking, .creditCard, .cash, .loan, .term, .asset, .shares, .investment ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(Self.typeOrder, id: \.self) { accountType in
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

                                    Spacer()

                                    // Expand or collapse indicator
                                    Image(systemName: expandedSections[accountType] == true ? "chevron.down" : "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    ) {
                        // Show account list based on expandedSections state
                        if expandedSections[accountType] == true,
                           let accounts = allAccountDataByType[accountType]
                        {
                            ForEach(accounts) { account in
                                // TODO: update View after change in account
                                NavigationLink(destination: AccountDetailView(
                                    allCurrencyName: $allCurrencyName,
                                    account: account
                                ) ) {
                                    HStack {
                                        Text(account.name)
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        if let currency = dataManager.currencyCache[account.currencyId] {
                                            Text(currency.name)
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
            .toolbar {
                Button(
                    action: { isPresentingAccountAddView = true },
                    label: { Image(systemName: "plus") }
                )
                .accessibilityLabel("New Account")
            }
        }
        .navigationTitle("Accounts")
        .onAppear {
            loadCurrencyName()
            loadAccountData()
        }
        .sheet(isPresented: $isPresentingAccountAddView) {
            AccountAddView(
                allCurrencyName: $allCurrencyName,
                newAccount: $newAccount,
                isPresentingAccountAddView: $isPresentingAccountAddView
            ) { newAccount in
                addAccount(account: &newAccount)
                newAccount = Self.emptyAccount
            }
        }
    }

    // Initialize the expanded state for each account type
    private func initializeExpandedSections() {
        for accountType in allAccountDataByType.keys {
            expandedSections[accountType] = true // Default to expanded
        }
    }
    
    func loadCurrencyName() {
        let repo = dataManager.currencyRepository
        DispatchQueue.global(qos: .background).async {
            let id_name = repo?.loadName() ?? []
            DispatchQueue.main.async {
                self.allCurrencyName = id_name
                // other post op
            }
        }
    }

    func loadAccountData() {
        print("Loading payees in AccountListView...")
        let repository = dataManager.accountRepository
        DispatchQueue.global(qos: .background).async {
            typealias A = AccountRepository
            let dataByType = repository?.loadByType(
                from: A.table.order(A.col_name)
            ) ?? [:]
            DispatchQueue.main.async {
                self.allAccountDataByType = dataByType
                self.initializeExpandedSections() // Initialize expanded states
            }
        }
    }

    func addAccount(account: inout AccountData) {
        guard let repository = dataManager.accountRepository else { return }
        if repository.insert(&account) {
            // self.accounts.append(account)
            if dataManager.currencyCache[account.currencyId] == nil {
                dataManager.loadCurrency()
            }
            dataManager.accountCache.update(id: account.id, data: account)
            self.loadAccountData()
        }
    }
}

#Preview {
    AccountListView(
        
    )
    .environmentObject(DataManager.sampleDataManager)
}

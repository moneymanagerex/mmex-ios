//
//  AccountView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//
import SwiftUI

struct AccountListView: View {
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment
    @State private var currencies: [(Int64, String)] = [] // only the name is needed
    @State private var accounts_by_type: [String:[AccountData]] = [:]
    @State private var newAccount = emptyAccount
    @State private var isPresentingAccountAddView = false
    @State private var expandedSections: [String: Bool] = [:] // Tracks the expanded/collapsed state
    static let emptyAccount = AccountData(
        status: AccountStatus.open
    )

    var body: some View {
        NavigationStack {
            List {
                ForEach(self.accounts_by_type.keys.sorted(), id: \.self) { accountType in
                    Section(
                        header: HStack {
                            Button(action: {
                                // Toggle expanded/collapsed state
                                expandedSections[accountType]?.toggle()
                            }) {
                                HStack {
                                    Image(systemName: AccountType(collateNoCase: accountType).symbolName)
                                        .frame(width: 5, alignment: .leading) // Adjust width as needed
                                        .font(.system(size: 16, weight: .bold)) // Customize size and weight
                                        .foregroundColor(.blue) // Customize icon style
                                    Text(accountType)
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
                        if expandedSections[accountType] == true {
                            ForEach(accounts_by_type[accountType]!) { account in
                                // TODO: update View after change in account
                                NavigationLink(destination: AccountDetailView(
                                    account: account, currencies: $currencies
                                ) ) {
                                    HStack {
                                        Text(account.name)
                                            .font(.subheadline)

                                        Spacer()

                                        if let currency = dataManager.currencyData[account.currencyId] {
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
                Button(action: {
                    isPresentingAccountAddView = true
                }, label: {
                    Image(systemName: "plus")
                })
                .accessibilityLabel("New Account")
            }
        }
        .navigationTitle("Accounts")
        .onAppear {
            loadAccounts()
            loadCurrencies()
        }
        .sheet(isPresented: $isPresentingAccountAddView) {
            AccountAddView(
                newAccount: $newAccount,
                isPresentingAccountAddView: $isPresentingAccountAddView,
                currencies: $currencies
            ) { newAccount in
                addAccount(account: &newAccount)
                newAccount = Self.emptyAccount
            }
        }
    }

    // Initialize the expanded state for each account type
    private func initializeExpandedSections() {
        for accountType in accounts_by_type.keys {
            expandedSections[accountType] = true // Default to expanded
        }
    }
    
    func loadAccounts() {
        print("Loading payees in AccountListView...")
        let repository = dataManager.accountRepository
        DispatchQueue.global(qos: .background).async {
            let loadedAccounts = repository?.load() ?? []
            DispatchQueue.main.async {
                self.accounts_by_type = Dictionary(grouping: loadedAccounts) { account in
                    account.type.name
                }
                self.initializeExpandedSections() // Initialize expanded states
            }
        }
    }
    
    func loadCurrencies() {
        let repo = dataManager.currencyRepository
        DispatchQueue.global(qos: .background).async {
            let loadedCurrencies = repo?.loadName() ?? []
            DispatchQueue.main.async {
                self.currencies = loadedCurrencies
                // other post op
            }
        }
    }

    func addAccount(account: inout AccountData) {
        guard let repository = dataManager.accountRepository else { return }
        if repository.insert(&account) {
            // self.accounts.append(account)
            if dataManager.currencyData[account.currencyId] == nil {
                dataManager.loadCurrency()
            }
            self.loadAccounts()
        }
    }
}

#Preview {
    AccountListView()
        .environmentObject(DataManager())
}

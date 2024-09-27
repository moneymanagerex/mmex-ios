//
//  AccountView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//
import SwiftUI

struct AccountListView: View {
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment
    @State private var currencies: [CurrencyData] = []
    @State private var accounts_by_type: [String:[AccountWithCurrency]] = [:]
    @State private var newAccount = AccountWithCurrency()
    @State private var isPresentingAccountAddView = false
    @State private var expandedSections: [String: Bool] = [:] // Tracks the expanded/collapsed state

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
                                NavigationLink(destination: AccountDetailView(account: account, currencies: $currencies)) {
                                    HStack {
                                        Text(account.data.name)
                                            .font(.subheadline)

                                        Spacer()

                                        if let currency = account.currency {
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
            AccountAddView(newAccount: $newAccount, isPresentingAccountAddView: $isPresentingAccountAddView, currencies: $currencies) { newAccount in
                addAccount(account: &newAccount)
                newAccount = AccountWithCurrency()
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
            let loadedAccounts = repository.loadWithCurrency()
            DispatchQueue.main.async {
                self.accounts_by_type = Dictionary(grouping: loadedAccounts) { account in
                    account.data.type.name
                }
                self.initializeExpandedSections() // Initialize expanded states
            }
        }
    }
    
    func loadCurrencies() {
        let repo = dataManager.currencyRepository

        DispatchQueue.global(qos: .background).async {
            let loadedCurrencies = repo.load()
            DispatchQueue.main.async {
                self.currencies = loadedCurrencies
                // other post op
            }
        }
    }

    func addAccount(account: inout AccountWithCurrency) {
        let repository = dataManager.accountRepository
        if repository.insert(&(account.data)) {
            // self.accounts.append(account)
            self.loadAccounts()
        }
    }
}

#Preview {
    AccountListView()
        .environmentObject(DataManager())
}

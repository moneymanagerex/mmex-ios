//
//  AccountView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//
import SwiftUI

struct AccountListView: View {
    let databaseURL: URL
    @State private var currencies: [Currency] = []
    @State private var accounts_by_type: [String:[Account]] = [:]
    @State private var newAccount = Account.empty
    @State private var isPresentingAccountAddView = false
    @State private var expandedSections: [String: Bool] = [:] // Tracks the expanded/collapsed state

    private var repository: AccountRepository

    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.repository = DataManager(databaseURL: databaseURL).getAccountRepository()
    }

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
                                    if let accountSymbol = Account.accountTypeToSFSymbol[accountType] {
                                        Image(systemName: accountSymbol)
                                            .frame(width: 5, alignment: .leading) // Adjust width as needed
                                            .font(.system(size: 16, weight: .bold)) // Customize size and weight
                                            .foregroundColor(.blue) // Customize icon style
                                    }
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
                                NavigationLink(destination: AccountDetailView(account: account, databaseURL: databaseURL, currencies: $currencies)) {
                                    HStack {
                                        Text(account.name)
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

        DispatchQueue.global(qos: .background).async {
            let loadedAccounts = repository.loadAccountsWithCurrency()
            DispatchQueue.main.async {
                self.accounts_by_type = Dictionary(grouping: loadedAccounts) { account in
                    account.type
                }
                self.initializeExpandedSections() // Initialize expanded states
            }
        }
    }
    
    func loadCurrencies() {
        let repo = DataManager(databaseURL: self.databaseURL).getCurrencyRepository()

        DispatchQueue.global(qos: .background).async {
            let loadedCurrencies = repo.loadCurrencies()
            DispatchQueue.main.async {
                self.currencies = loadedCurrencies
                // other post op
            }
        }
    }

    func addAccount(account: inout Account) {
        if repository.addAccount(account: &account) {
            // self.accounts.append(account)
            self.loadAccounts()
        }
    }
}

#Preview {
    AccountListView(databaseURL: URL(string: "path/to/database")!)
}

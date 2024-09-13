//
//  AccountView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//
import SwiftUI

struct AccountListView: View {
    let databaseURL: URL
    @State private var accounts: [Account] = []
    @State private var currencies: [Currency] = []
    @State private var currencyDict: [Int64 : Currency] = [:] // lookup
    @State private var accounts_by_type: [String:[Account]] = [:]
    @State private var newAccount = Account.empty
    @State private var isPresentingAccountAddView = false
    
    private var repository: AccountRepository
    
    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.repository = DataManager(databaseURL: databaseURL).getAccountRepository()
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(self.accounts_by_type.keys.sorted(), id:\.self) { accountType in
                    Section(
                        header: HStack {
                            if let accountSymbol = Account.accountTypeToSFSymbol[accountType] {
                                Image(systemName: accountSymbol)
                                    .frame(width: 5, alignment: .leading) // Adjust width as needed
                                    .font(.system(size: 16, weight: .bold)) // Customize size and weight
                                    .foregroundColor(.blue) // Customize icon style
                            }
                            Text(accountType)
                                .font(.subheadline)
                                .padding(.leading)
                        }
                    ) {
                        ForEach(accounts_by_type[accountType]!) { account in
                            NavigationLink(destination: AccountDetailView(account: account, databaseURL: databaseURL, currencies: $currencies)) {
                                HStack{
                                    Text(account.name)
                                        .font(.subheadline)

                                    Spacer()

                                    if let currency = self.currencyDict[account.id] {
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
    
    func loadAccounts() {
        print("Loading payees in AccountListView...")

        DispatchQueue.global(qos: .background).async {
            let loadedAccounts = repository.loadAccounts()
            DispatchQueue.main.async {
                self.accounts = loadedAccounts
                self.accounts_by_type = Dictionary(grouping: accounts) { account in
                    account.type
                }
            }
        }
    }
    
    func loadCurrencies() {
        let repo = DataManager(databaseURL: self.databaseURL).getCurrencyRepository()

        DispatchQueue.global(qos: .background).async {
            let loadedCurrencies = repo.loadCurrencies()
            DispatchQueue.main.async {
                self.currencies = loadedCurrencies
                self.currencyDict = Dictionary(uniqueKeysWithValues: currencies.map { ($0.id, $0) })
                // other post op
            }
        }
    }

    func addAccount(account: inout Account) {
        if repository.addAccount(account: &account) {
            self.accounts.append(account)
        }
    }
}

#Preview {
    AccountListView(databaseURL: URL(string: "path/to/database")!)
}

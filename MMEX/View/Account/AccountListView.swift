//
//  AccountListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import SwiftUI

struct AccountListView: View {
    @EnvironmentObject var env: EnvironmentManager

    @State private var allCurrencyName: [(Int64, String)] = [] // sorted by name
    @State private var allAccountDataByType: [AccountType: [AccountData]] = [:] // sorted by name
    @State private var isTypeVisible:  [AccountType: Bool] = [:]
    @State private var isTypeExpanded: [AccountType: Bool] = [:]
    @State private var search: String = ""
    @State private var isPresentingAddView = false
    @State private var newAccount = emptyAccount

    static let emptyAccount = AccountData(
        status       : .open,
        favoriteAcct : .boolTrue
    )

    static let typeOrder: [AccountType] = [ .checking, .creditCard, .cash, .loan, .term, .asset, .shares, .investment ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(Self.typeOrder, id: \.self) { accountType in
                    if isTypeVisible[accountType] == true {
                        Section(
                            header: HStack {
                                Button(action: {
                                    // Toggle expanded/collapsed state
                                    isTypeExpanded[accountType]?.toggle()
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
                                        Image(systemName: isTypeExpanded[accountType] == true ? "chevron.down" : "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        ) {
                            // Show account list based on expanded state
                            if isTypeExpanded[accountType] == true,
                               let accounts = allAccountDataByType[accountType]
                            {
                                ForEach(accounts) { account in
                                    // TODO: update View after change in account
                                    if search.isEmpty || match(account, search) {
                                        itemView(account)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .toolbar {
                Button(
                    action: { isPresentingAddView = true },
                    label: { Image(systemName: "plus") }
                )
                .accessibilityLabel("New Account")
            }
            .searchable(text: $search, prompt: "Search by name")
            .textInputAutocapitalization(.never)
            .onChange(of: search) { _, value in
                filterType(by: value)
            }
        }
        .navigationTitle("Accounts")
        .onAppear {
            loadCurrencyName()
            loadAccountData()
        }
        .sheet(isPresented: $isPresentingAddView) {
            AccountAddView(
                allCurrencyName: $allCurrencyName,
                newAccount: $newAccount,
                isPresentingAddView: $isPresentingAddView
            ) { newAccount in
                addAccount(account: &newAccount)
                newAccount = Self.emptyAccount
            }
        }
    }

    func itemView(_ account: AccountData) -> some View {
        NavigationLink(destination: AccountDetailView(
            allCurrencyName: $allCurrencyName,
            account: account
        ) ) {
            HStack {
                Text(account.name)
                    .font(.subheadline)
                
                Spacer()
                
                if let currency = env.currencyCache[account.currencyId] {
                    Text(currency.name)
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)
        }
    }

    // Initialize the expanded state for each account type
    private func initializeType() {
        for accountType in allAccountDataByType.keys {
            isTypeVisible[accountType] = true
            isTypeExpanded[accountType] = true // Default to expanded
        }
    }

    func filterType(by search: String) {
        for accountType in allAccountDataByType.keys {
            let matched = search.isEmpty || allAccountDataByType[accountType]?.first(where: { match($0, search) }) != nil
            isTypeVisible[accountType] = matched
            if matched { isTypeExpanded[accountType] = true }
        }
    }

    func match(_ account: AccountData, _ search: String) -> Bool {
        account.name.localizedCaseInsensitiveContains(search)
    }

    func loadCurrencyName() {
        let repo = env.currencyRepository
        DispatchQueue.global(qos: .background).async {
            let id_name = repo?.loadName() ?? []
            DispatchQueue.main.async {
                self.allCurrencyName = id_name
            }
        }
    }

    func loadAccountData() {
        let repository = env.accountRepository
        DispatchQueue.global(qos: .background).async {
            typealias A = AccountRepository
            let dataByType = repository?.loadByType(
                from: A.table.order(A.col_name)
            ) ?? [:]
            DispatchQueue.main.async {
                self.allAccountDataByType = dataByType
                self.initializeType()
            }
        }
    }

    func addAccount(account: inout AccountData) {
        guard let repository = env.accountRepository else { return }
        if repository.insert(&account) {
            // self.accounts.append(account)
            if env.currencyCache[account.currencyId] == nil {
                env.loadCurrency()
            }
            env.accountCache.update(id: account.id, data: account)
            self.loadAccountData()
        }
    }
}

#Preview {
    AccountListView(
    )
    .environmentObject(EnvironmentManager.sampleData)
}

//
//  AccountListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//
import SwiftUI

struct AccountListView: View {
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment
    @State private var currencyName: [(Int64, String)] = [] // only the name is needed
    @State private var accountIdByType: [AccountType: [Int64]] = [:]
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
                           let ids: [Int64] = accountIdByType[accountType],
                           !ids.isEmpty
                        {
                            ForEach(ids, id: \.self) { id in
                                if let account = dataManager.accountData[id] {
                                    // TODO: update View after change in account
                                    NavigationLink(destination: AccountDetailView(
                                        account: account, currencyName: $currencyName
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
                currencyName: $currencyName
            ) { newAccount in
                addAccount(account: &newAccount)
                newAccount = Self.emptyAccount
            }
        }
    }

    // Initialize the expanded state for each account type
    private func initializeExpandedSections() {
        for accountType in accountIdByType.keys {
            expandedSections[accountType] = true // Default to expanded
        }
    }
    
    func loadAccounts() {
        print("Loading payees in AccountListView...")
        let repository = dataManager.accountRepository
        DispatchQueue.global(qos: .background).async {
            typealias A = AccountRepository
            let idByType = repository?.loadByType(
                from: A.table.order(A.col_name),
                with: { row in row[A.col_id] }
            ) ?? [:]
            DispatchQueue.main.async {
                self.accountIdByType = idByType
                self.initializeExpandedSections() // Initialize expanded states
            }
        }
    }
    
    func loadCurrencies() {
        let repo = dataManager.currencyRepository
        DispatchQueue.global(qos: .background).async {
            let id_name = repo?.loadName() ?? []
            DispatchQueue.main.async {
                self.currencyName = id_name
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
            dataManager.updateAccount(id: account.id, data: account)
            self.loadAccounts()
        }
    }
}

#Preview {
    AccountListView()
        .environmentObject(DataManager())
}

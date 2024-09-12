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
                            NavigationLink(destination: AccountDetailView(account: account, databaseURL: databaseURL)) {
                                HStack {
                                    Text(account.name)
                                    // Text(account.status.id)
                                    // TODO layout and more informationn
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
        }
        .sheet(isPresented: $isPresentingAccountAddView) {
            AccountAddView(newAccount: $newAccount, isPresentingAccountAddView: $isPresentingAccountAddView) { newAccount in
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
    
    func addAccount(account: inout Account) {
        if repository.addAccount(account: &account) {
            self.accounts.append(account)
        }
    }
}

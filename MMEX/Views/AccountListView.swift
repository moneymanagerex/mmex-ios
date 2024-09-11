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
    @State private var newAccount = Account.empty
    @State private var isPresentingAccountAddView = false
    
    private var repository: AccountRepository
    
    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.repository = DataManager(databaseURL: databaseURL).getAccountRepository()
    }
    
    var body: some View {
        NavigationStack {
            List(accounts) { account in
                NavigationLink(destination: AccountDetailView(account: account, databaseURL: databaseURL)) {
                    Text(account.name)
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
            }
        }
    }
    
    func addAccount(account: inout Account) {
        if repository.addAccount(account: &account) {
            self.accounts.append(account)
        }
    }
}

//
//  ManagementView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct ManagementView: View {
    let databaseURL: URL
    @Binding var isDocumentPickerPresented: Bool
    
    @State private var currencies: [Currency] = []
    @State private var accounts: [Account] = []
    @State private var schemaVersion: Int32 = 0
    @State private var dateFormat: String = ""
    @State private var baseCurrencyID: Int64 = 0
    @State private var defaultAccountID: Int64 = 0
    
    var body: some View {
        List {
            Section(header: Text("Manage Data")) {
                NavigationLink(destination: AccountListView(databaseURL: databaseURL)) {
                    Text("Manage Accounts")
                }
                NavigationLink(destination: PayeeListView(databaseURL: databaseURL)) {
                    Text("Manage Payees")
                }
                NavigationLink(destination: CategoryListView(databaseURL: databaseURL)) {
                    Text("Manage Categories")
                }
                NavigationLink(destination: TransactionListView(databaseURL: databaseURL)) {
                    Text("Manage Transactions")
                }
                NavigationLink(destination: CurrencyListView(databaseURL: databaseURL)) {
                    Text("Manage Currencies")
                }
            }

            // Section: Default Behavior Setting
            Section(header: Text("Per-Database Data")) {
                HStack {
                    Text("Schema Version")
                    Spacer()
                    Text("\(schemaVersion)")
                }
                HStack {
                    Text("Date Format")
                    Spacer()
                    Text("\(dateFormat)")
                }
                Picker("Base Currency", selection: $baseCurrencyID) {
                    ForEach(currencies) { currency in
                        Text(currency.name).tag(currency.id) // Use currency.name to display and tag by id
                    }
                }
                .pickerStyle(NavigationLinkPickerStyle())
                .onChange(of: baseCurrencyID) { baseCurrencyID in
                    let repository = DataManager(databaseURL: databaseURL).getInfotableRepository()
                    repository.setValue(baseCurrencyID, for: InfoKey.baseCurrencyID.id)
                }
 
                Picker("Default Account", selection: $defaultAccountID) {
                    ForEach(accounts) { account in
                        Text(account.name).tag(account.id)
                    }
                }
                .pickerStyle(NavigationLinkPickerStyle())
                .onChange(of: defaultAccountID) { defaultAccountID in
                    let repository = DataManager(databaseURL: databaseURL).getInfotableRepository()
                    repository.setValue(defaultAccountID, for: InfoKey.defaultAccountID.id)
                }
            }
            
            Section(header: Text("Database")) {
                Button("Re-open Database") {
                    isDocumentPickerPresented = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .onAppear() {
            loadAccounts()
            loadCurrencies()
            let repository = DataManager(databaseURL: databaseURL).getInfotableRepository()
            schemaVersion = repository.db?.userVersion ?? 0
            if let storedDateFormat = repository.getValue(for: InfoKey.dateFormat.id, as: String.self) {
                dateFormat = storedDateFormat
            }
            if let storedBaseCurrency = repository.getValue(for:InfoKey.baseCurrencyID.id, as: Int64.self) {
                baseCurrencyID = storedBaseCurrency
            }
            
            if let storedDefaultAccount = repository.getValue(for: InfoKey.defaultAccountID.id, as: Int64.self) {
                defaultAccountID = storedDefaultAccount
            }
        }
        .navigationTitle("Management")
    }
    
    func loadAccounts() {
        print("Loading payees in ManagementView...")

        let repo = DataManager(databaseURL: self.databaseURL).getAccountRepository()

        DispatchQueue.global(qos: .background).async {
            let loadedAccounts = repo.loadAccountsWithCurrency()
            DispatchQueue.main.async {
                self.accounts = loadedAccounts
                
                if (loadedAccounts.count == 1) {
                    defaultAccountID = loadedAccounts.first!.id
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
                
                if (loadedCurrencies.count == 1) {
                    baseCurrencyID = loadedCurrencies.first!.id
                }
            }
        }
    }
}

/*
#Preview {
    ManagementView(databaseURL: URL(string: "path/to/database")!, isDocumentPickerPresented: .constant(false))
}

#Preview {
    ManagementView(databaseURL: URL(string: "path/to/database")!, isDocumentPickerPresented: .constant(true))
}
*/

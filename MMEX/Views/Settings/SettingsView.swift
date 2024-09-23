//
//  SettingsView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct SettingsView: View {
    let databaseURL: URL
    
    @AppStorage("defaultPayeeSetting") private var defaultPayeeSetting: DefaultPayeeSetting = .none
    @AppStorage("defaultStatus") private var defaultStatus: TransactionStatus = .none

    @State private var currencies: [Currency] = []
    @State private var accounts: [Account] = []
    @State private var schemaVersion: Int32 = 19
    @State private var dateFormat: String = "%Y-%m-%d"
    @State private var baseCurrencyID: Int64 = 0
    @State private var defaultAccountID: Int64 = 0

    var body: some View {
        List {
            // Section: App Information
            Section(header: Text("App Information")) {
                NavigationLink(destination: AboutView()) {
                    Text("About")
                }
                NavigationLink(destination: VersionInfoView()) {
                    Text("Version")
                }
                NavigationLink(destination: LegalView()) {
                    Text("Legal (Terms & Privacy)")
                }
            }
            
            // Section: Support and Help
            Section(header: Text("Support and Help")) {
                NavigationLink(destination: HelpFAQView()) {
                    Text("Help / FAQ")
                }
                NavigationLink(destination: ContactSupportView()) {
                    Text("Contact Support")
                }
            }
            // Section: Default Behavior Setting
            Section(header: Text("Behavior")) {
                Picker("Default Payee", selection: $defaultPayeeSetting) {
                    Text("None").tag(DefaultPayeeSetting.none)
                    Text("Last Used").tag(DefaultPayeeSetting.lastUsed)
                }
                .pickerStyle(NavigationLinkPickerStyle())
 
                Picker("Default Status", selection: $defaultStatus) {
                    ForEach(TransactionStatus.allCases) { status in
                        Text(status.fullName).tag(status)
                    }
                }
                .pickerStyle(NavigationLinkPickerStyle())
            }
            // Section: Default Behavior Setting
            Section(header: Text("Per-Database Behavior")) {
                HStack {
                    Text("Database File")
                    Spacer()
                    Text(databaseURL.lastPathComponent)
                }
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
                        HStack {
                            Text(currency.symbol)
                            Spacer()
                            Text(currency.name)
                        }
                        .tag(currency.id) // Use currency.name to display and tag by id
                    }
                }
                .pickerStyle(NavigationLinkPickerStyle())
                .onChange(of: baseCurrencyID) { baseCurrencyID in
                    let repository = DataManager(databaseURL: databaseURL).getInfotableRepository()
                    repository.setValue(baseCurrencyID, for: InfoKey.baseCurrencyID.id)
                }
 
                Picker("Default Account", selection: $defaultAccountID) {
                    ForEach(accounts) { account in
                        HStack {
                            Text(account.name)
                            Spacer()
                            Text(account.currency?.symbol ?? "")
                        }
                        .tag(account.id)
                    }
                }
                .pickerStyle(NavigationLinkPickerStyle())
                .onChange(of: defaultAccountID) { defaultAccountID in
                    let repository = DataManager(databaseURL: databaseURL).getInfotableRepository()
                    repository.setValue(defaultAccountID, for: InfoKey.defaultAccountID.id)
                }
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
    }
    func loadAccounts() {
        print("Loading payees in ManagementView...")

        let repo = DataManager(databaseURL: self.databaseURL).getAccountRepository()

        DispatchQueue.global(qos: .background).async {
            let loadedAccounts = repo.loadWithCurrency()
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
            let loadedCurrencies = repo.load()
            DispatchQueue.main.async {
                self.currencies = loadedCurrencies
                
                if (loadedCurrencies.count == 1) {
                    baseCurrencyID = loadedCurrencies.first!.id
                }
            }
        }
    }
}

enum DefaultPayeeSetting: String, CaseIterable, Identifiable {
    case none = "None"
    case lastUsed = "Last Used"

    var id: String { rawValue }
}

#Preview {
    SettingsView(databaseURL: URL(string: "path/to/database")!)
}

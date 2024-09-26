//
//  SettingsView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: InfotableViewModel
    
    @AppStorage("defaultPayeeSetting") private var defaultPayeeSetting: DefaultPayeeSetting = .none
    @AppStorage("defaultStatus") private var defaultStatus = TransactionStatus.defaultValue

    @State private var dateFormat: String = "%Y-%m-%d"

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
                    // Text(viewModel.databaseURL.lastPathComponent)
                }
                HStack {
                    Text("Schema Version")
                    Spacer()
                    Text("\(viewModel.getSchemaVersion())")
                }
                HStack {
                    Text("Date Format")
                    Spacer()
                    Text("\(dateFormat)")
                }
                Picker("Base Currency", selection: $viewModel.baseCurrencyId) {
                    ForEach(viewModel.currencies) { currency in
                        HStack {
                            Text(currency.symbol)
                            Spacer()
                            Text(currency.name)
                        }
                        .tag(currency.id) // Use currency.name to display and tag by id
                    }
                }
                .pickerStyle(NavigationLinkPickerStyle())
 
                Picker("Default Account", selection: $viewModel.defaultAccountId) {
                    ForEach(viewModel.accounts) { account in
                        HStack {
                            Text(account.data.name)
                            Spacer()
                            Text(account.currency?.symbol ?? "")
                        }
                        .tag(account.id)
                    }
                }
                .pickerStyle(NavigationLinkPickerStyle())
            }
        }
        .onAppear() {
            // TODO
        }
    }
}

enum DefaultPayeeSetting: String, CaseIterable, Identifiable {
    case none = "None"
    case lastUsed = "Last Used"

    var id: String { rawValue }
}

#Preview {
    SettingsView(viewModel: InfotableViewModel(databaseURL: URL(string: "path/to/database")!))
}

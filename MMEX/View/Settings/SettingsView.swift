//
//  SettingsView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel
    @ObservedObject var viewModel: TransactionViewModel

    @AppStorage("appearance") private var appearance: Int = UIUserInterfaceStyle.unspecified.rawValue
    @AppStorage("defaultPayeeSetting") private var defaultPayeeSetting: DefaultPayeeSetting = .none
    @AppStorage("defaultStatus") private var defaultStatus = TransactionStatus.defaultValue

    @State private var dateFormat: String = "%Y-%m-%d"

    var body: some View {
        List {
            Section(header: Text("App Settings")) {
                Picker("Appearance", selection: $appearance) {
                    Text("System").tag(UIUserInterfaceStyle.unspecified.rawValue)
                    Text("Light").tag(UIUserInterfaceStyle.light.rawValue)
                    Text("Dark").tag(UIUserInterfaceStyle.dark.rawValue)
                }
                .pickerStyle(NavigationLinkPickerStyle())
                .onChange(of: appearance) {
                    Appearance.apply(appearance)
                }

                NavigationLink(destination: SettingsThemeView()) {
                    Text("Theme")
                }

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

            Section(header: Text("Database Settings")) {
                HStack {
                    Text("Database File")
                    Spacer()
                    Text(env.getDatabaseFileName() ?? "")
                }
                HStack {
                    Text("Schema Version")
                    Spacer()
                    Text(String(env.getDatabaseUserVersion() ?? 0))
                }
                HStack {
                    Text("Date Format")
                    Spacer()
                    Text("\(dateFormat)")
                }
                HStack {
                    Text("Category Delimiter")
                    Spacer()
                    Text("\(viewModel.categDelimiter)")
                }
                Picker("Base Currency", selection: $viewModel.baseCurrencyId) {
                    ForEach(viewModel.currencies) { currency in
                        HStack {
                            Text(currency.name)
                            //Spacer()
                            //Text(currency.symbol)
                        }
                        .tag(currency.id) // Use currency.name to display and tag by id
                    }
                }
                .pickerStyle(NavigationLinkPickerStyle())
 
                Picker("Default Account", selection: $viewModel.defaultAccountId) {
                    if viewModel.defaultAccountId.isVoid {
                        HStack { Text("(none)") }
                            .tag(DataId.void)
                    }
                    ForEach(viewModel.accounts) { account in
                        HStack { Text(account.name) }
                            .tag(account.id)
                    }
                }
                .pickerStyle(NavigationLinkPickerStyle())
            }

            Section(header: Text("Information")) {
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
            
            Section(header: Text("Support and Help")) {
                NavigationLink(destination: HelpFAQView()) {
                    Text("Help / FAQ")
                }
                NavigationLink(destination: ContactSupportView()) {
                    Text("Contact Support")
                }
            }
        }
        .onAppear() {
            // TODO
        }
    }
}

enum Appearance {
    static func apply(_ appearance: Int) {
        //log.debug("DEBUG: appearance: \(appearance)")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: appearance) ?? .unspecified
                window.reloadInputViews()
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
    let env = EnvironmentManager.sampleData
    SettingsView(
        vm: ViewModel(env: env),
        viewModel: TransactionViewModel(env: env)
    )
    .environmentObject(env)
}

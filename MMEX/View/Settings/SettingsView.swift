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

    @AppStorage("defaultPayeeSetting") private var defaultPayeeSetting: DefaultPayeeSetting = .none
    @AppStorage("defaultStatus") private var defaultStatus = TransactionStatus.defaultValue
    @AppStorage("isTrackingEnabled") private var isTrackingEnabled: Bool = false // Default is tracking disabled

    @State private var dateFormat: String = "%Y-%m-%d"

    var body: some View {
        List {
            Section(header: Text("App Settings")) {
                NavigationLink(destination: SettingsThemeView()) {
                    Text("Theme")
                }

                Picker("Send Anonymous Usage Data", selection: $isTrackingEnabled) {
                    Text("On").tag(true)
                    Text("Off").tag(false)
                }
                .pickerStyle(NavigationLinkPickerStyle())
                .onChange(of: isTrackingEnabled) {
                    // TODO
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
                    Text("\((vm.infotableList.categoryDelimiter.readyValue ?? nil) ?? ":")")
                }

                // TODO: add search
                // TODO: reload Infotable
                Picker("Base Currency", selection: $viewModel.baseCurrencyId) {
                    if viewModel.baseCurrencyId.isVoid {
                        Text("(none)").tag(DataId.void)
                    }
                    ForEach(vm.currencyList.order.readyValue ?? []) { id in
                        if let currencyName = vm.currencyList.name.readyValue?[id] {
                            Text(currencyName).tag(id)
                        }
                    }
                }
                .pickerStyle(NavigationLinkPickerStyle())
 
                // TODO: add search
                // TODO: reload Infotable
                Picker("Default Account", selection: $viewModel.defaultAccountId) {
                    if viewModel.defaultAccountId.isVoid {
                        Text("(none)").tag(DataId.void)
                    }
                    ForEach(vm.accountList.order.readyValue ?? []) { id in
                        if let account = vm.accountList.data.readyValue?[id] {
                            Text(account.name).tag(id)
                        }
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
            
            Section(header: Text("Support")) {
                NavigationLink(destination: HelpFAQView()) {
                    Text("Help / FAQ")
                }
                NavigationLink(destination: ContactSupportView()) {
                    Text("Contact Support")
                }
            }
        }
        .task {
            log.trace("DEBUG: SettingsView.load(main=\(Thread.isMainThread))")
            await vm.loadSettingsList()
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

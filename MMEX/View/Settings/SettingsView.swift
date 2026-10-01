//
//  SettingsView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @StateObject private var viewModel = SettingsViewModel()

    let groupTheme = GroupTheme(layout: .nameFold)
    @State var dbSettingsIsExpanded = false
    
    var body: some View {
        List {
            groupTheme.section(
                nameView: { Text("App Settings") }
            ) {
                NavigationLink(destination: ThemeView()
                    .navigationTitle("Theme")
                ) {
                    Text("Theme")
                }
                
                Picker("Default Transaction Status", selection: $pref.enter.defaultStatus) {
                    ForEach(TransactionStatus.allCases) { status in
                        Text(status.fullName).tag(status)
                    }
                }

                /*
                HStack {
                    Text("Reuse Last Account")
                    Spacer()
                    Toggle(isOn: $env.pref.reuseLastAccount.asBool) { }
                }

                HStack {
                    Text("Reuse Last Category")
                    Spacer()
                    Toggle(isOn: $env.pref.reuseLastCategory.asBool) { }
                }
                 */

                HStack {
                    Text("Reuse Last Payee")
                    Spacer()
                    Toggle(isOn: $pref.enter.reuseLastPayee.asBool) { }
                }
                
                HStack {
                    Text("Send Anonymous Usage Data")
                    Spacer()
                    Toggle(isOn: $pref.track.sendUsage.asBool) { }
                }
            }
            
            groupTheme.section(
                nameView: { Text("Database Settings") }
                //isExpanded: $dbSettingsIsExpanded
            ) {
                if let currencyName = vm.currencyList.name.readyValue {
                    Picker("Base Currency", selection: $viewModel.baseCurrencyId) {
                        ForEach(viewModel.currencyOptions(from: vm.currencyList)) { id in
                            if id.isVoid {
                                Text("(none)").tag(id)
                            } else if let name = currencyName[id] {
                                Text(name).tag(id)
                            }
                        }
                    }
                    .onChange(of: viewModel.baseCurrencyId) {
                        Task { await viewModel.updateBaseCurrency(using: vm) }
                    }
                }

                if let accountData = vm.accountList.data.readyValue {
                    Picker("Default Account", selection: $viewModel.defaultAccountId) {
                        ForEach(viewModel.accountOptions(from: vm.accountList)) { id in
                            if id.isVoid {
                                Text("(none)").tag(id)
                            } else if let name = accountData[id]?.name {
                                Text(name).tag(id)
                            }
                        }
                    }
                    .onChange(of: viewModel.defaultAccountId) {
                        Task { await viewModel.updateDefaultAccount(using: vm) }
                    }
                }
            }
            
            groupTheme.section(
                nameView: { Text("App Info") }
            ) {
                NavigationLink(destination: InfoAboutView()
                    .navigationTitle("About")
                ) {
                    Text("About")
                }

                NavigationLink(destination: InfoVersionView()
                    .navigationTitle("Version")
                ) {
                    HStack {
                        Text("Version")
                        if let version = InfoVersionView.appVersionBuild {
                            Spacer()
                            Text(version)
                        }
                    }
                }

                NavigationLink(destination: LegalView()
                    .navigationTitle("Legal")
                ) {
                    Text("Legal")
                }

                NavigationLink(destination: InfoHelpView()
                    .navigationTitle("Help")
                ) {
                    Text("Help")
                }

                NavigationLink(destination: InfoContactView()
                    .navigationTitle("Contact")
                ) {
                    Text("Contact")
                }
            }
            
            groupTheme.section(
                nameView: { Text("Database Info") }
            ) {
                HStack {
                    Text("Database File")
                    Spacer()
                    Text(vm.getDatabaseFileName() ?? "")
                }

                HStack {
                    Text("Schema Version")
                    Spacer()
                    Text(String(vm.getDatabaseUserVersion() ?? 0))
                }

                HStack {
                    Text("SQLite Version")
                    Spacer()
                    Text(vm.sqliteVersion?.description ?? "")
                }
            }
        }
        .listStyle(InsetGroupedListStyle()) // Better styling for iOS
        .listSectionSpacing(5)
        .padding(.top, -20)
        //.border(.red)

        .task {
            log.trace("DEBUG: SettingsView.task(main=\(Thread.isMainThread))")
            await viewModel.load(from: vm, preference: pref)
        }

        .refreshable {
            log.trace("DEBUG: SettingsView.refreshable(main=\(Thread.isMainThread))")
            await viewModel.refresh(from: vm, preference: pref)
        }

        .alert(isPresented: Binding(
            get: { viewModel.isAlertPresented },
            set: { if !$0 { viewModel.dismissAlert() } }
        )) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.alertMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    MMEXPreview.tab("Settings") { pref, vm in
        SettingsView(
        )
    }
}

extension MMEXPreview {
    @ViewBuilder
    static func settings<Content: View>(
        _ title: String,
        @ViewBuilder content: @escaping (_ pref: Preference, _ vm: ViewModel) -> Content
    ) -> some View {
        MMEXPreview.tab("Settings") { pref, vm in
            content(pref, vm)
                .navigationTitle(title)
        }
    }
}

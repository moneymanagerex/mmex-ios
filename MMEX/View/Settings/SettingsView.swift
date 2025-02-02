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

    let groupTheme = GroupTheme(layout: .nameFold)
    @State var dbSettingsIsExpanded = false

    @State var baseCurrencyId    : DataId = .void
    @State var defaultAccountId  : DataId = .void

    @State private var alertIsPresented = false
    @State private var alertMessage: String?
    
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
                    Picker("Base Currency", selection: $baseCurrencyId) {
                        ForEach(baseCurrencyOffer) { id in
                            if id.isVoid {
                                Text("(none)").tag(id)
                            } else if let name = currencyName[id] {
                                Text(name).tag(id)
                            }
                        }
                    }
                    .onChange(of: baseCurrencyId) {
                        baseCurrencyUpdate()
                    }
                }

                if let accountData = vm.accountList.data.readyValue {
                    Picker("Default Account", selection: $defaultAccountId) {
                        ForEach(defaultAccountOffer) { id in
                            if id.isVoid {
                                Text("(none)").tag(id)
                            } else if let name = accountData[id]?.name {
                                Text(name).tag(id)
                            }
                        }
                    }
                    .onChange(of: defaultAccountId) {
                        defaultAccountUpdate()
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
            await vm.loadSettingsList(pref)
            baseCurrencyId    = vm.infotableList.baseCurrencyId.value
            defaultAccountId  = vm.infotableList.defaultAccountId.value
        }

        .refreshable {
            log.trace("DEBUG: SettingsView.refreshable(main=\(Thread.isMainThread))")
            vm.unloadAll()
            await vm.loadSettingsList(pref)
            baseCurrencyId    = vm.infotableList.baseCurrencyId.value
            defaultAccountId  = vm.infotableList.defaultAccountId.value
        }

        .alert(isPresented: $alertIsPresented) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage!),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    var baseCurrencyOffer: [DataId] {
        var offer: [DataId] = []
        var isAppended = baseCurrencyId.isVoid
        // always offer .void
        if true || baseCurrencyId.isVoid {
            offer.append(.void)
        }
        for id in vm.currencyList.order.readyValue ?? [] {
            // offer used currencies
            if id == baseCurrencyId || vm.currencyList.used.readyValue?.contains(id) == true {
                offer.append(id)
                if id == baseCurrencyId { isAppended = true }
            }
        }
        // offer currentId
        if !isAppended { offer.append(baseCurrencyId) }
        return offer
    }

    func baseCurrencyUpdate() {
        guard baseCurrencyId != vm.infotableList.baseCurrencyId.value else { return }
        let updateError = vm.updateSettings(baseCurrencyId: baseCurrencyId)
        if updateError != nil {
            baseCurrencyId = vm.infotableList.baseCurrencyId.value
            alertMessage = updateError
            alertIsPresented = true
        } else {
            Task {
                await vm.reloadSettings(baseCurrencyId: baseCurrencyId)
            }
        }
    }
    
    var defaultAccountOffer: [DataId] {
        var offer: [DataId] = []
        var isAppended = defaultAccountId.isVoid
        // always offer .void
        if true || defaultAccountId.isVoid {
            offer.append(.void)
        }
        for id in vm.accountList.order.readyValue ?? [] {
            // offer open accounts
            if id == defaultAccountId || vm.accountList.data.readyValue?[id]?.status == .open {
                offer.append(id)
                if id == defaultAccountId { isAppended = true }
            }
        }
        // offer defaultAccountId
        if !isAppended { offer.append(defaultAccountId) }
        return offer
    }

    func defaultAccountUpdate() {
        guard defaultAccountId != vm.infotableList.defaultAccountId.value else { return }
        let updateError = vm.updateSettings(defaultAccountId: defaultAccountId)
        if updateError != nil {
            defaultAccountId = vm.infotableList.defaultAccountId.value
            alertMessage = updateError
            alertIsPresented = true
        } else {
            Task {
                await vm.reloadSettings(defaultAccountId: defaultAccountId)
            }
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

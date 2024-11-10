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
    
    let groupTheme = GroupTheme(layout: .nameFold)
    @State var dbSettingsIsExpanded = false
    @FocusState private var categoryDelimiterFocus: Bool
    
    @State var baseCurrencyId    : DataId = .void
    @State var defaultAccountId  : DataId = .void
    @State var categoryDelimiter : String = ":"
    
    @State private var alertIsPresented = false
    @State private var alertMessage: String?
    
    @AppStorage("defaultPayeeSetting") private var defaultPayeeSetting: DefaultPayeeSetting = .none
    @AppStorage("defaultStatus") private var defaultStatus = TransactionStatus.defaultValue
    @AppStorage("isTrackingEnabled") private var isTrackingEnabled: Bool = false // Default is tracking disabled
    
    @State private var dateFormat: String = "%Y-%m-%d"
    
    var body: some View {
        List {
            groupTheme.section(
                nameView: { Text("App Settings") }
            ) {
                NavigationLink(destination: SettingsThemeView()) {
                    Text("Theme")
                }
                
                Picker("Default Payee", selection: $defaultPayeeSetting) {
                    Text("None").tag(DefaultPayeeSetting.none)
                    Text("Last Used").tag(DefaultPayeeSetting.lastUsed)
                }
                .pickerStyle(NavigationLinkPickerStyle())
                
                Picker("Default Transaction Status", selection: $defaultStatus) {
                    ForEach(TransactionStatus.allCases) { status in
                        Text(status.fullName).tag(status)
                    }
                }
                .pickerStyle(NavigationLinkPickerStyle())
                
                Picker("Send Anonymous Usage Data", selection: $isTrackingEnabled) {
                    Text("On").tag(true)
                    Text("Off").tag(false)
                }
                .pickerStyle(NavigationLinkPickerStyle())
                .onChange(of: isTrackingEnabled) {
                    // TODO
                }
            }
            
            groupTheme.section(
                nameView: { Text("Database Settings") }
                //isExpanded: $dbSettingsIsExpanded
            ) {
                Picker("Base Currency", selection: $baseCurrencyId) {
                    ForEach(baseCurrencyOffer) { id in
                        if id.isVoid {
                            Text("(none)").tag(id)
                        } else if let name = vm.currencyList.name.readyValue?[id] {
                            Text(name).tag(id)
                        }
                    }
                }
                .onChange(of: baseCurrencyId) {
                    baseCurrencyUpdate()
                }
                
                Picker("Default Account", selection: $defaultAccountId) {
                    ForEach(defaultAccountOffer) { id in
                        if id.isVoid {
                            Text("(none)").tag(id)
                        } else if let name = vm.accountList.data.readyValue?[id]?.name {
                            Text(name).tag(id)
                        }
                    }
                }
                .onChange(of: defaultAccountId) {
                    defaultAccountUpdate()
                }

                HStack {
                    Text("Category Delimiter")
                    Spacer()
                    TextField("Default is ':'", text: $categoryDelimiter)
                        .focused($categoryDelimiterFocus)
                        .onChange(of: categoryDelimiterFocus) {
                            if !categoryDelimiterFocus { currencyDelimiterUpdate() }
                        }
                        .textInputAutocapitalization(.never)
                        // problem: trailing space is not visible
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 100)
                    Menu {
                        ForEach(categoryDelimiterSuggestion, id: \.self) { s in
                            Button("'\(s)'") {
                                categoryDelimiter = s
                                currencyDelimiterUpdate()
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.footnote)
                    }
                }
            }
            
            groupTheme.section(
                nameView: { Text("App Info") }
            ) {
                NavigationLink(destination: AboutView()) {
                    Text("About")
                }
                NavigationLink(destination: VersionInfoView()) {
                    HStack {
                        Text("Version")
                        if let version = VersionInfoView.appVersionBuild {
                            Spacer()
                            Text(version)
                        }
                    }
                }
                NavigationLink(destination: LegalView()) {
                    Text("Legal")
                }
                NavigationLink(destination: HelpFAQView()) {
                    Text("Help")
                }
                NavigationLink(destination: ContactSupportView()) {
                    Text("Contact")
                }
            }
            
            groupTheme.section(
                nameView: { Text("Database Info") }
            ) {
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
            }
        }
        .listStyle(InsetGroupedListStyle()) // Better styling for iOS
        .listSectionSpacing(5)
        .padding(.top, -20)
        //.border(.red)
        .task {
            log.trace("DEBUG: SettingsView.load(main=\(Thread.isMainThread))")
            await vm.loadSettingsList()
            baseCurrencyId    = vm.infotableList.baseCurrencyId.value
            defaultAccountId  = vm.infotableList.defaultAccountId.value
            categoryDelimiter = vm.infotableList.categoryDelimiter.value
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

    var categoryDelimiterSuggestion: [String] { [
        ".",
        ":", " : ",
        "/", " / ",
        " ▶ ", " ❯ ",
    ] }
    
    func currencyDelimiterUpdate() {
        if categoryDelimiter.isEmpty { categoryDelimiter = ":" }
        guard categoryDelimiter != vm.infotableList.categoryDelimiter.value else { return }
        let updateError = vm.updateSettings(categoryDelimiter: categoryDelimiter)
        if updateError != nil {
            categoryDelimiter = vm.infotableList.categoryDelimiter.value
            alertMessage = updateError
            alertIsPresented = true
        } else {
            Task {
                await vm.reloadSettings(categoryDelimiter: categoryDelimiter)
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

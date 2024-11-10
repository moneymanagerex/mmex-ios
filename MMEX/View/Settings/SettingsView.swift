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
            Section(header: Text("App Settings")) {
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

                Picker("Base Currency", selection: $baseCurrencyId) {
                    ForEach(baseCurrencyOffer(baseCurrencyId)) { id in
                        if id.isVoid {
                            Text("(none)").tag(id)
                        } else if let name = vm.currencyList.name.readyValue?[id] {
                            Text(name).tag(id)
                        }
                    }
                }
                //.pickerStyle(NavigationLinkPickerStyle())
                .onChange(of: baseCurrencyId) {
                    guard baseCurrencyId != vm.infotableList.baseCurrencyId.value else { return }
                    let updateError = vm.updateInfotable(baseCurrencyId: baseCurrencyId)
                    if updateError != nil {
                        baseCurrencyId = vm.infotableList.baseCurrencyId.value
                        alertMessage = updateError
                        alertIsPresented = true
                    } else {
                        Task {
                            await vm.reloadInfotable(baseCurrencyId: baseCurrencyId)
                        }
                    }
                }
 
                // TODO: add search
                Picker("Default Account", selection: $defaultAccountId) {
                    if defaultAccountId.isVoid {
                        Text("(none)").tag(DataId.void)
                    }
                    ForEach(vm.accountList.order.readyValue ?? []) { id in
                        if let account = vm.accountList.data.readyValue?[id] {
                            Text(account.name).tag(id)
                        }
                    }
                }
                .pickerStyle(NavigationLinkPickerStyle())
                .onChange(of: defaultAccountId) {
                    // TODO: reload Infotable
                }

                HStack {
                    Text("Category Delimiter")
                    Spacer()
                    TextField("N/A", text: $categoryDelimiter)
                        .textInputAutocapitalization(.sentences)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: categoryDelimiter) {
                            // TODO: update infotable
                        }
                }
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
        .listSectionSpacing(5)
        .padding(.top, -20)
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
    
    func baseCurrencyOffer(_ currentId: DataId) -> [DataId] {
        var offer: [DataId] = []
        var isAppended = currentId.isVoid
        // always offer .void
        if true || currentId.isVoid {
            offer.append(.void)
        }
        for id in vm.currencyList.order.readyValue ?? [] {
            // offer used currencies
            if id == currentId || vm.currencyList.used.readyValue?.contains(id) == true {
                offer.append(id)
                if id == currentId { isAppended = true }
            }
        }
        // offer currentId
        if !isAppended { offer.append(currentId) }
        return offer
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

//
//  ContentView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import SwiftUI
import UIKit

struct ContentView: View {
    private static let overviewTab = 0
    private static let screenshotSampleDataKey = "MMEX_SCREENSHOT_SAMPLE_DATA"
    private static let screenshotScreenKey = "MMEX_SCREENSHOT_SCREEN"

    enum ScreenshotScreen: String {
        case overview
        case journal
        case insights
        case enter
        case manage
        case settings
    }

    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @State private var isDocumentPickerPresented = false
    @State private var isSetupPresented = false
    @State private var stagedDatabaseURL: URL?
    @State private var saveRequest: DatabaseSaveRequest?
    @State private var setupError: String?
    @State private var pendingSaveError: String?
    @State private var isAttachDocumentPickerPresented = false
    @State private var isSampleDocument = false
    @State private var selectedTab = Preference.selectedTab
    @State private var isPresentingTransactionAddView = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @State private var isPasswordPromptVisible = false
    @State private var password = ""
    @State private var fileURL: URL?
    @State private var isPasswordValid = true // Flag to validate password
    @State private var iPadReturnTab = ContentView.overviewTab
    @State private var iPadDetailResetKey = 0

    private var screenshotScreen: ScreenshotScreen? {
        ProcessInfo.processInfo.environment[Self.screenshotScreenKey]
            .flatMap(ScreenshotScreen.init(rawValue:))
    }

    private var shouldAutoLoadSampleData: Bool {
        ProcessInfo.processInfo.environment[Self.screenshotSampleDataKey] == "1"
    }

    var body: some View {
        ZStack {
            if vm.isDatabaseConnected {
                if let screenshotScreen {
                    screenshotConnectedView(screen: screenshotScreen)
                } else {
                    connectedView
                }
            } else {
                disconnectedView
            }
        }
        
        .handlesExternalEvents(preferring: Set(["mmb", "emb"]), allowing: Set(["*"]))
        .onOpenURL { url in
            if url.pathExtension.lowercased() == "mmb" {
                vm.openDatabase(at: url)
            } else {
                // If the file is emb, prompt for password
                fileURL = url
                isPasswordPromptVisible = true
            }
        }

        .fileImporter(
            isPresented: $isDocumentPickerPresented,
            allowedContentTypes: [.mmb, .emb],
            allowsMultipleSelection: false
        ) {
            handleFileImport($0)
        }
        .sheet(isPresented: $isPasswordPromptVisible) {
            // Password input sheet
            VStack {
                Text("Password Required")
                    .font(.headline)
                    .padding()

                SecureField("Enter password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom)

                if !isPasswordValid {
                    Text("Invalid password, please try again.")
                        .foregroundColor(.red)
                        .padding(.bottom)
                }

                HStack {
                    Button("Cancel") {
                        isPasswordPromptVisible = false
                    }
                    .padding()

                    Button("OK") {
                        validateAndOpenDatabase()
                    }
                    .padding()
                }
            }
            .padding()
            .frame(width: 300, height: 200)
        }

        .sheet(isPresented: $isSetupPresented, onDismiss: {
            if let url = stagedDatabaseURL {
                saveRequest = DatabaseSaveRequest(url: url)
            }
        }) {
            NewDatabaseSetupView { setup, chooseLocation in
                if chooseLocation {
                    stagedDatabaseURL = try vm.prepareDatabaseForExport(setup)
                } else {
                    try vm.createConfiguredDatabase(setup)
                    selectedTab = ContentView.overviewTab
                }
            }
        }
        .sheet(item: $saveRequest, onDismiss: {
            cleanupStagedDatabase()
            setupError = pendingSaveError
            pendingSaveError = nil
        }) { request in
            NavigationStack {
                DatabaseSavePicker(url: request.url) { result in
                    if let result {
                        do {
                            try vm.openExportedDatabase(at: result)
                            selectedTab = ContentView.overviewTab
                        } catch {
                            log.error("Saved database could not be opened: \(error)")
                            pendingSaveError = String(localized: "The database was saved, but could not be opened. Open it from Files.")
                        }
                    }
                    saveRequest = nil
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { saveRequest = nil }
                    }
                }
            }
        }
        .alert("Could not create database", isPresented: Binding(
            get: { setupError != nil },
            set: { if !$0 { setupError = nil } }
        )) {
            Button("OK", role: .cancel) { setupError = nil }
        } message: {
            Text(setupError ?? "")
        }

        .autocorrectionDisabled()
        .onAppear {
            guard shouldAutoLoadSampleData, !vm.isDatabaseConnected else { return }
            vm.createDatabase(at: nil, sampleData: true)
            guard vm.isDatabaseConnected else { return }
            selectedTab = horizontalSizeClass == .regular ? ContentView.overviewTab : Preference.selectedTab
        }
    }

    @ViewBuilder
    private var connectedView: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView {
                SidebarView(selectedTab: $selectedTab, onSelectTab: selectIpadTab) {
                    iPadReturnTab = selectedTab == 2 ? ContentView.overviewTab : selectedTab
                    isPresentingTransactionAddView = true
                }
            } detail: {
                NavigationStack {
                    TabContentView(
                        selectedTab: detailTabBinding,
                        isDocumentPickerPresented: $isDocumentPickerPresented,
                        isNewDocumentPickerPresented: $isSetupPresented,
                        isAttachDocumentPickerPresented: $isAttachDocumentPickerPresented,
                        isSampleDocument: $isSampleDocument
                    )
                }
                .id("\(detailTabSelection)-\(iPadDetailResetKey)")
            }
            .sheet(isPresented: $isPresentingTransactionAddView) {
                NavigationStack {
                    EnterView(
                        selectedTab: iPadEnterSelectionBinding
                    )
                }
            }
            .onAppear {
                if selectedTab == Preference.selectedTab {
                    selectedTab = ContentView.overviewTab
                    iPadReturnTab = ContentView.overviewTab
                }
            }
        } else {
            TabView(selection: $selectedTab) {
                overviewTab()
                // journalTab()
                // insightsTab()
                enterTab()
                manageTab()
                settingsTab()
            }
            .onChange(of: selectedTab) { _, tab in
                if tab == 2 { isPresentingTransactionAddView = true }
            }
        }
    }

    private var disconnectedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "wallet.pass.fill")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            Text("Your finances, your data")
                .font(.title.bold())
            Text("Create a personal database or open an existing MMEX file.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: { isSetupPresented = true }) {
                Label("Get Started", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button(action: { isDocumentPickerPresented = true }) {
                Label("Open Existing Database", systemImage: "folder")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Menu {
                Button("Create Sample Database") {
                    do {
                        stagedDatabaseURL = try vm.prepareSampleDatabaseForExport()
                        if let url = stagedDatabaseURL {
                            saveRequest = DatabaseSaveRequest(url: url)
                        }
                    } catch {
                        log.error("Failed to prepare sample database: \(error)")
                        setupError = error.localizedDescription
                    }
                }
                Button("Try Sample Data in Memory") {
                    vm.createDatabase(at: nil, sampleData: true)
                    guard vm.isDatabaseConnected else { return }
                    selectedTab = ContentView.overviewTab
                }
            } label: {
                Label("Explore sample data", systemImage: "sparkles")
            }
        }
        .padding()
        .frame(maxWidth: 420)
        .onAppear {
            vm.unloadAll()
        }
    }

    @ViewBuilder
    private func screenshotConnectedView(screen: ScreenshotScreen) -> some View {
        NavigationStack {
            switch screen {
            case .overview:
                OverviewView()
                    .navigationBarTitle("Overview", displayMode: .inline)
            case .journal:
                JournalView()
                    .navigationBarTitle("Journal", displayMode: .inline)
            case .insights:
                InsightsView()
                    .navigationBarTitle("Insights", displayMode: .inline)
            case .enter:
                EnterView(selectedTab: $selectedTab)
                    .navigationBarTitle("Enter", displayMode: .inline)
            case .manage:
                ManageView(
                    isDocumentPickerPresented: $isDocumentPickerPresented,
                    isNewDocumentPickerPresented: $isSetupPresented,
                    isAttachDocumentPickerPresented: $isAttachDocumentPickerPresented,
                    isSampleDocument: $isSampleDocument
                )
                .navigationBarTitle("Manage", displayMode: .inline)
            case .settings:
                SettingsView()
                    .navigationBarTitle("Settings", displayMode: .inline)
            }
        }
    }

    private func overviewTab() -> some View {
        NavigationStack {
            OverviewView()
                .navigationBarTitle("Overview", displayMode: .inline)
        }
        .tabItem {
            pref.theme.tab.iconText(icon: "house.fill", text: "Overview")
        }
        .tag(0)
    }

    private func journalTab() -> some View {
        NavigationView {
            if selectedTab == 0 {
                JournalView()
                    .navigationBarTitle("Journal", displayMode: .inline)
            }
        }
        .tabItem {
            pref.theme.tab.iconText(icon: "list.bullet", text: "Journal")
        }
        .tag(0)
    }

    private func insightsTab() -> some View {
        NavigationView {
            if selectedTab == 1 {
                InsightsView()
                    .navigationBarTitle("Insights", displayMode: .inline)
            }
        }
        .tabItem {
            pref.theme.tab.iconText(icon: "arrow.up.right", text: "Insights")
        }
        .tag(1)
    }

    private func enterTab() -> some View {
        NavigationView {
            EnterView(selectedTab: $selectedTab)
                .navigationBarTitle("Enter", displayMode: .inline)
        }
        .tabItem {
            pref.theme.tab.iconText(icon: "plus.circle", text: "Enter")
        }
        .tag(2)
    }

    private func manageTab() -> some View {
        // note: NavigationStack and @Environment(\.dismiss) hands the app
        NavigationView {
            ManageView(
                isDocumentPickerPresented: $isDocumentPickerPresented,
                isNewDocumentPickerPresented: $isSetupPresented,
                isAttachDocumentPickerPresented: $isAttachDocumentPickerPresented,
                isSampleDocument: $isSampleDocument
            )
            .navigationBarTitle("Manage", displayMode: .inline)
            //.navigationTitle("Manage")
            //.navigationBarTitleDisplayMode(.inline)
        }
        .tabItem {
            pref.theme.tab.iconText(icon: "folder", text: "Manage")
        }
        .tag(3)
    }

    // Settings tab
    private func settingsTab() -> some View {
        NavigationView {
            SettingsView()
                .navigationBarTitle("Settings", displayMode: .inline)
        }
        .tabItem {
            pref.theme.tab.iconText(icon: "gearshape", text: "Settings")
        }
        .tag(4)
    }

    // File import handling
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                if url.pathExtension.lowercased() == "mmb" {
                    vm.openDatabase(at: url)
                    guard vm.isDatabaseConnected else { return }
                } else {
                    // Prompt for password if it's an emb file
                    fileURL = url
                    isPasswordPromptVisible = true
                }
                log.info("Successfully opened database: \(url)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedTab = horizontalSizeClass == .regular ? ContentView.overviewTab : Preference.selectedTab
                }
            }
        case .failure(let error):
            log.error("Failed to pick a document: \(error.localizedDescription)")
        }
    }

    // Validate and open the database using the entered password
    private func validateAndOpenDatabase() {
        guard !password.isEmpty else {
            // Invalid password, show error
            isPasswordValid = false
            return
        }
        // Open the database with the provided password
        if let url = fileURL {
            vm.openDatabase(at: url, password: password)
            guard vm.isDatabaseConnected else {
                isPasswordValid = false
                return
            }
            // Hide the password prompt
            isPasswordPromptVisible = false
        }
    }
    
    private func cleanupStagedDatabase() {
        guard let url = stagedDatabaseURL else { return }
        stagedDatabaseURL = nil
        do {
            try FileManager.default.removeItem(at: url.deletingLastPathComponent())
        } catch {
            log.error("Failed to remove temporary database: \(error)")
        }
    }
}

private struct DatabaseSaveRequest: Identifiable {
    let id = UUID()
    let url: URL
}

private struct DatabaseSavePicker: UIViewControllerRepresentable {
    let url: URL
    let completion: (URL?) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: [url], asCopy: false)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ controller: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(completion: completion) }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let completion: (URL?) -> Void

        init(completion: @escaping (URL?) -> Void) {
            self.completion = completion
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            completion(urls.first)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            completion(nil)
        }
    }
}

private struct NewDatabaseSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: ViewModel
    let onCreate: (NewDatabaseSetup, Bool) throws -> Void

    @State private var currencies: [CurrencyData] = []
    @State private var currencyId: DataId = .void
    @State private var accountName = String(localized: "Everyday account")
    @State private var accountType: AccountType = .checking
    @State private var initialBalance = 0.0
    @State private var chooseLocation = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Set up your first account. You can change these details and add more accounts later.")
                        .foregroundStyle(.secondary)
                }
                Section {
                    Picker("Currency", selection: $currencyId) {
                        ForEach(currencies, id: \.id) { currency in
                            Text("\(currency.localizedName()) (\(currency.symbol))").tag(currency.id)
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("Base Currency")
                } footer: {
                    Text("Used for your first account and overall totals.")
                }
                Section("First Account") {
                    TextField("Account name", text: $accountName)
                    Picker("Account type", selection: $accountType) {
                        Text("Checking").tag(AccountType.checking)
                        Text("Cash").tag(AccountType.cash)
                        Text("Credit Card").tag(AccountType.creditCard)
                        Text("Term").tag(AccountType.term)
                    }
                    TextField("Starting balance", value: $initialBalance, format: .number)
                        .keyboardType(.numbersAndPunctuation)
                }
                Section {
                    Toggle("Choose a save location", isOn: $chooseLocation)
                } footer: {
                    Text("By default, the database is saved on this device in Files under On My iPhone or On My iPad. It is not automatically synced. Back it up before deleting the app.")
                }
                Section {
                    Label("Common categories are included. No sample transactions are added.", systemImage: "checkmark.circle")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Create Your Database")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let setup = NewDatabaseSetup(
                            currencyId: currencyId,
                            accountName: accountName.trimmingCharacters(in: .whitespacesAndNewlines),
                            accountType: accountType,
                            initialBalance: initialBalance
                        )
                        do {
                            try onCreate(setup, chooseLocation)
                            dismiss()
                        } catch {
                            log.error("Failed to create database: \(error)")
                            errorMessage = error.localizedDescription
                        }
                    } label: {
                        if chooseLocation { Text("Continue") } else { Text("Create") }
                    }
                    .disabled(currencyId.isVoid || accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .task {
                do {
                    currencies = try vm.availableSetupCurrencies()
                    let preferredCode = Locale.current.currency?.identifier
                    currencyId = (currencies.first { $0.symbol == preferredCode }
                        ?? currencies.first { $0.symbol == "USD" }
                        ?? currencies[0]).id
                } catch {
                    log.error("Failed to load setup currencies: \(error)")
                    errorMessage = error.localizedDescription
                }
            }
            .alert("Could not create database", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
}

struct SidebarView: View {
    @Binding var selectedTab: Int
    let onSelectTab: (Int) -> Void
    let onAddTransaction: () -> Void

    private let selectableTabs: [(tab: Int, title: String, systemImage: String)] = [
        (0, "Overview", "house.fill"),
        (3, "Manage", "folder"),
        (4, "Settings", "gearshape")
    ]

    var body: some View {
        VStack(spacing: 0) {
            List(selection: sidebarSelection) {
                ForEach(selectableTabs, id: \.tab) { item in
                    Label(item.title, systemImage: item.systemImage)
                        .tag(item.tab)
                }
            }
            .listStyle(SidebarListStyle())

            Divider()
                .padding(.vertical, 8)

            Button(action: onAddTransaction) {
                Label("Enter", systemImage: "plus.circle")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)
        }
    }

    private var sidebarSelection: Binding<Int?> {
        Binding(
            get: { selectedTab },
            set: { newValue in
                guard let newValue else { return }
                onSelectTab(newValue)
            }
        )
    }
}

extension ContentView {
    private func selectIpadTab(_ tab: Int) {
        selectedTab = tab
        iPadDetailResetKey += 1
    }

    private var detailTabSelection: Int {
        selectedTab == 2 ? iPadReturnTab : selectedTab
    }

    private var iPadEnterSelectionBinding: Binding<Int> {
        Binding(
            get: { selectedTab },
            set: { newValue in
                if newValue == Preference.selectedTab {
                    selectedTab = iPadReturnTab
                } else {
                    selectedTab = newValue
                }
            }
        )
    }

    private var detailTabBinding: Binding<Int> {
        Binding(
            get: { detailTabSelection },
            set: { selectedTab = $0 }
        )
    }
}

struct TabContentView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @Binding var selectedTab: Int
    @Binding var isDocumentPickerPresented: Bool
    @Binding var isNewDocumentPickerPresented: Bool
    @Binding var isAttachDocumentPickerPresented: Bool
    @Binding var isSampleDocument: Bool

    var body: some View {
        log.trace("TabContentView.body")
        // Use @StateObject to manage the lifecycle of TransactionViewModel
        // Here we ensure that there's no additional NavigationStack or NavigationView
        return Group {
            switch selectedTab {
            case 0:
                OverviewView()
                    .navigationBarTitle("Overview", displayMode: .inline)
            case 1:
                InsightsView()
                    .navigationBarTitle("Insights", displayMode: .inline)
            case 2:
                EnterView(selectedTab: $selectedTab)
                    .navigationBarTitle("Enter", displayMode: .inline)
            case 3:
                ManageView(
                    isDocumentPickerPresented: $isDocumentPickerPresented,
                    isNewDocumentPickerPresented: $isNewDocumentPickerPresented,
                    isAttachDocumentPickerPresented: $isAttachDocumentPickerPresented,
                    isSampleDocument: $isSampleDocument
                )
                .navigationBarTitle("Manage", displayMode: .inline)
            case 4:
                SettingsView()
                    .navigationBarTitle("Settings", displayMode: .inline)
            default:
                EmptyView()
            }
        }
        .navigationBarTitleDisplayMode(.inline) // Ensure that title is inline, preventing stacking
    }
}

#Preview("disconnected") {
    MMEXPreview.appWithoutData { pref, vm in
        ContentView(
        )
    }
}

#Preview("connected") {
    MMEXPreview.appWithSampleData { pref, vm in
        ContentView(
        )
    }
}

extension MMEXPreview {
    @ViewBuilder
    static func tab<Content: View>(
        _ title: String,
        @ViewBuilder content: @escaping (_ pref: Preference, _ vm: ViewModel) -> Content
    ) -> some View {
        MMEXPreview.appWithSampleData { pref, vm in NavigationView {
            content(pref, vm)
                .navigationBarTitle(title, displayMode: .inline)
        } }
    }
}

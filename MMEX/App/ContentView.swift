//
//  ContentView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var env: EnvironmentManager
    @StateObject private var vm: ViewModel
    @State private var isDocumentPickerPresented = false
    @State private var isNewDocumentPickerPresented = false
    @State private var isSampleDocument = false
    @State private var selectedTab = 0
    @State private var selectedFileURL: URL?
    @State private var isPresentingTransactionAddView = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    init(env: EnvironmentManager) {
        log.debug("DEBUG: ContentView.init()")
        //self.vm = ViewModel(env: env)
        self._vm = StateObject(wrappedValue: ViewModel(env: env))
    }

    var body: some View {
        ZStack {
            if env.isDatabaseConnected {
                connectedView
            } else {
                disconnectedView
            }
        }

        .fileImporter(
            isPresented: $isDocumentPickerPresented,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) {
            handleFileImport($0)
        }

        .fileExporter(
            isPresented: $isNewDocumentPickerPresented,
            document: MMEXDocument(),
            contentType: .mmb,
            defaultFilename: isSampleDocument ? "Sample.mmb" : "Untitled.mmb"
        ) {
            handleFileExport($0)
        }

        .autocorrectionDisabled()
    }

    @ViewBuilder
    private var connectedView: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView {
                SidebarView(selectedTab: $selectedTab)
            } detail: {
                TabContentView(
                    vm: vm,
                    selectedTab: $selectedTab,
                    isDocumentPickerPresented: $isDocumentPickerPresented,
                    isNewDocumentPickerPresented: $isNewDocumentPickerPresented,
                    isSampleDocument: $isSampleDocument
                )
            }
        } else {
            // problem: if VM is declared here, it is re-instantiated on switching between tabs
            // fix: move VM declaration to View and initialize it in init()
            //let vm = RepositoryViewModel(env: env)
            let insightsViewModel = InsightsViewModel(env: env)
            let infotableViewModel = TransactionViewModel(env: env)
            TabView(selection: $selectedTab) {
                journalTab(vm: vm, viewModel: infotableViewModel)
                insightsTab(vm: vm, viewModel: insightsViewModel)
                enterTab(vm: vm, viewModel: infotableViewModel)
                managementTab(vm: vm, viewModel: infotableViewModel)
                settingsTab(vm: vm, viewModel: infotableViewModel)
            }
            .onChange(of: selectedTab) { _, tab in
                if tab == 2 { isPresentingTransactionAddView = true }
            }
        }
    }

    private var disconnectedView: some View {
        VStack(spacing: 30) {
            Image(systemName: "tray.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.accentColor)
            Text("No Database Connected")
                .font(.headline)
                .padding(.bottom, 10)
            Text("Please open or create a database to get started.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: { isDocumentPickerPresented = true }) {
                Label("Open Database", systemImage: "folder.fill")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button(action: { isNewDocumentPickerPresented = true; isSampleDocument = false }) {
                Label("Create New Database", systemImage: "plus.app.fill")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button(action: { isNewDocumentPickerPresented = true; isSampleDocument = true }) {
                Label("Create Sample Database", systemImage: "doc.text.fill")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button(action: {
                env.createDatabase(at: nil, sampleData: true)
                guard env.isDatabaseConnected else { return }
                log.info("Successfully created sample database in memory")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedTab = 0
                }
            }) {
                Label("Sample Database in Memory", systemImage: "memorychip.fill")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding()
        .onAppear {
            vm.unloadAll()
        }
    }

    // Transaction tab
    private func journalTab(vm: ViewModel, viewModel: TransactionViewModel) -> some View {
        NavigationView {
            JournalView(vm: vm, viewModel: viewModel)
                .navigationBarTitle("Latest Transactions", displayMode: .inline)
        }
        .tabItem {
            pref.theme.tab.iconText(icon: "list.bullet", text: "Journal")
        }
        .tag(0)
    }

    // Insights tab
    private func insightsTab(vm: ViewModel, viewModel: InsightsViewModel) -> some View {
        NavigationView {
            InsightsView(vm: vm, viewModel: viewModel)
                .navigationBarTitle("Insights", displayMode: .inline)
        }
        .tabItem {
            pref.theme.tab.iconText(icon: "arrow.up.right", text: "Insights")
        }
        .tag(1)
    }

    // Add transaction tab
    private func enterTab(vm: ViewModel, viewModel: TransactionViewModel) -> some View {
        NavigationView {
            EnterView(vm: vm, viewModel: viewModel, selectedTab: $selectedTab)
                // .navigationBarTitle("Enter Transaction", displayMode: .inline)
        }
        .tabItem {
            pref.theme.tab.iconText(icon: "plus.circle", text: "Enter")
        }
        .tag(2)
    }

    // Management tab
    private func managementTab(
        vm: ViewModel,
        viewModel: TransactionViewModel
    ) -> some View {
        NavigationView {
            ManageView(
                vm: vm,
                viewModel: viewModel,
                isDocumentPickerPresented: $isDocumentPickerPresented,
                isNewDocumentPickerPresented: $isNewDocumentPickerPresented,
                isSampleDocument: $isSampleDocument
            )
            .navigationBarTitle("Manage", displayMode: .inline)
        }
        .tabItem {
            pref.theme.tab.iconText(icon: "folder", text: "Manage")
        }
        .tag(3)
    }

    // Settings tab
    private func settingsTab(vm: ViewModel, viewModel: TransactionViewModel) -> some View {
        NavigationView {
            SettingsView(vm: vm, viewModel: viewModel)
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
                env.openDatabase(at: url)
                guard env.isDatabaseConnected else { return }
                log.info("Successfully opened database: \(url)")
                UserDefaults.standard.set(url.path, forKey: "SelectedFilePath")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedTab = 0
                }
            }
        case .failure(let error):
            log.error("Failed to pick a document: \(error.localizedDescription)")
        }
    }

    // File export handling
    private func handleFileExport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            env.createDatabase(at: url, sampleData: isSampleDocument)
            guard env.isDatabaseConnected else { return }
            log.info("Successfully created database: \(url)")
            UserDefaults.standard.set(url.path, forKey: "SelectedFilePath")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                selectedTab = 0
            }
        case .failure(let error):
            log.error("Failed to pick a document: \(error.localizedDescription)")
        }
    }
}

struct SidebarView: View {
    @Binding var selectedTab: Int

    var body: some View {
        List {
            Button(action: { selectedTab = 0 }) {
                Label("Checking", systemImage: "list.bullet")
            }
            Button(action: { selectedTab = 1 }) {
                Label("Insights", systemImage: "arrow.up.right")
            }
            Button(action: { selectedTab = 2 }) {
                Label("Enter", systemImage: "plus.circle")
            }
            Button(action: { selectedTab = 3 }) {
                Label("Manage", systemImage: "folder")
            }
            Button(action: { selectedTab = 4 }) {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .listStyle(SidebarListStyle()) // Ensure it's displayed as a proper sidebar
    }
}

struct TabContentView: View {
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel
    @Binding var selectedTab: Int
    @Binding var isDocumentPickerPresented: Bool
    @Binding var isNewDocumentPickerPresented: Bool
    @Binding var isSampleDocument: Bool

    var body: some View {
        log.trace("TabContentView.body")
        // Use @StateObject to manage the lifecycle of TransactionViewModel
        let insightsViewModel = InsightsViewModel(env: env)
        let infotableViewModel = TransactionViewModel(env: env)
        // Here we ensure that there's no additional NavigationStack or NavigationView
        return Group {
            switch selectedTab {
            case 0:
                JournalView(vm: vm, viewModel: infotableViewModel) // Summary and Edit feature
                    .navigationBarTitle("Latest Transactions", displayMode: .inline)
            case 1:
                InsightsView(vm: vm, viewModel: insightsViewModel)
                    .navigationBarTitle("Reports and Insights", displayMode: .inline)
            case 2:
                EnterView(vm: vm, viewModel: infotableViewModel, selectedTab: $selectedTab)
                    .navigationBarTitle("Enter Transaction", displayMode: .inline)
            case 3:
                ManageView(
                    vm: vm,
                    viewModel:infotableViewModel,
                    isDocumentPickerPresented: $isDocumentPickerPresented,
                    isNewDocumentPickerPresented: $isNewDocumentPickerPresented,
                    isSampleDocument: $isSampleDocument
                )
                .navigationBarTitle("Manage", displayMode: .inline)
            case 4:
                SettingsView(vm: vm, viewModel: infotableViewModel)
                    .navigationBarTitle("Settings", displayMode: .inline)
            default:
                EmptyView()
            }
        }
        .navigationBarTitleDisplayMode(.inline) // Ensure that title is inline, preventing stacking
    }
}

#Preview(){
    let env = EnvironmentManager.sampleData
    ContentView(
        env: env
    )
    .environmentObject(env)
}

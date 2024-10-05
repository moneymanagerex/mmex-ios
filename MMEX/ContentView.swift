//
//  ContentView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import SwiftUI

struct ContentView: View {
    @State private var isDocumentPickerPresented = false
    @State private var isNewDocumentPickerPresented = false
    @State private var isSampleDocument = false
    @State private var selectedTab = 0
    @State private var selectedFileURL: URL?
    @State private var isPresentingTransactionAddView = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var env: EnvironmentManager

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
        ) { handleFileImport($0) }
        .fileExporter(
            isPresented: $isNewDocumentPickerPresented,
            document: MMEXDocument(),
            contentType: .mmb,
            defaultFilename: isSampleDocument ? "Sample.mmb" : "Untitled.mmb"
        ) { handleFileExport($0) }
    }

    private var connectedView: some View {
        Group {
            if horizontalSizeClass == .regular {
                NavigationSplitView {
                    SidebarView(selectedTab: $selectedTab)
                } detail: {
                    TabContentView(
                        selectedTab: $selectedTab,
                        isDocumentPickerPresented: $isDocumentPickerPresented,
                        isNewDocumentPickerPresented: $isNewDocumentPickerPresented,
                        isSampleDocument: $isSampleDocument
                    )
                }
            } else {
                let insightsViewModel = InsightsViewModel(env: env)
                let infotableViewModel = InfotableViewModel(env: env)
                TabView(selection: $selectedTab) {
                    transactionTab(viewModel: infotableViewModel)
                    insightsTab(viewModel: insightsViewModel)
                    addTransactionTab(viewModel: infotableViewModel)
                    managementTab(viewModel: infotableViewModel)
                    settingsTab(viewModel: infotableViewModel)
                }
                .onChange(of: selectedTab) { _, tab in
                    if tab == 2 { isPresentingTransactionAddView = true }
                }
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
                .font(.title)
                .padding(.bottom, 10)
            Text("Please open an existing database or create a new one to get started.")
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
                Label("Use Sample Database", systemImage: "doc.text.fill")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding()
    }

    // Transaction tab
    private func transactionTab(viewModel: InfotableViewModel) -> some View {
        NavigationView {
            TransactionListView2(viewModel: viewModel)
                .navigationBarTitle("Latest Transactions", displayMode: .inline)
        }
        .tabItem {
            env.theme.tab.iconText(icon: "list.bullet", text: "Checking")
        }
        .tag(0)
    }

    // Insights tab
    private func insightsTab(viewModel: InsightsViewModel) -> some View {
        NavigationView {
            InsightsView(viewModel: viewModel)
                .navigationBarTitle("Reports and Insights", displayMode: .inline)
        }
        .tabItem {
            env.theme.tab.iconText(icon: "arrow.up.right", text: "Insights")
        }
        .tag(1)
    }

    // Add transaction tab
    private func addTransactionTab(viewModel: InfotableViewModel) -> some View {
        NavigationView {
            TransactionAddView2(viewModel: viewModel, selectedTab: $selectedTab)
                .navigationBarTitle("Add Transaction", displayMode: .inline)
        }
        .tabItem {
            env.theme.tab.iconText(icon: "plus.circle", text: "Add Transaction")
        }
        .tag(2)
    }

    // Management tab
    private func managementTab(viewModel: InfotableViewModel) -> some View {
        NavigationView {
            ManagementView(
                viewModel:viewModel,
                isDocumentPickerPresented: $isDocumentPickerPresented,
                isNewDocumentPickerPresented: $isNewDocumentPickerPresented,
                isSampleDocument: $isSampleDocument
            )
            .navigationBarTitle("Management", displayMode: .inline)
        }
        .tabItem {
            env.theme.tab.iconText(icon: "folder", text: "Management")
        }
        .tag(3)
    }

    // Settings tab
    private func settingsTab(viewModel: InfotableViewModel) -> some View {
        NavigationView {
            SettingsView(viewModel: viewModel)
                .navigationBarTitle("Settings", displayMode: .inline)
        }
        .tabItem {
            env.theme.tab.iconText(icon: "gearshape", text: "Settings")
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
                Label("Add Transaction", systemImage: "plus.circle")
            }
            Button(action: { selectedTab = 3 }) {
                Label("Management", systemImage: "folder")
            }
            Button(action: { selectedTab = 4 }) {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .listStyle(SidebarListStyle()) // Ensure it's displayed as a proper sidebar
    }
}

struct TabContentView: View {
    @Binding var selectedTab: Int
    @Binding var isDocumentPickerPresented: Bool
    @Binding var isNewDocumentPickerPresented: Bool
    @Binding var isSampleDocument: Bool
    @EnvironmentObject var env: EnvironmentManager // Access EnvironmentManager

    var body: some View {
        log.trace("TabContentView.body")
        // Use @StateObject to manage the lifecycle of InfotableViewModel
        let infotableViewModel = InfotableViewModel(env: env)
        // Here we ensure that there's no additional NavigationStack or NavigationView
        return Group {
            switch selectedTab {
            case 0:
                TransactionListView2(viewModel: infotableViewModel) // Summary and Edit feature
                    .navigationBarTitle("Latest Transactions", displayMode: .inline)
            case 1:
                InsightsView(viewModel: InsightsViewModel(env: env))
                    .navigationBarTitle("Reports and Insights", displayMode: .inline)
            case 2:
                TransactionAddView2(viewModel: infotableViewModel, selectedTab: $selectedTab)
                    .navigationBarTitle("Add Transaction", displayMode: .inline)
            case 3:
                ManagementView(
                    viewModel:infotableViewModel,
                    isDocumentPickerPresented: $isDocumentPickerPresented,
                    isNewDocumentPickerPresented: $isNewDocumentPickerPresented,
                    isSampleDocument: $isSampleDocument
                )
                .navigationBarTitle("Management", displayMode: .inline)
            case 4:
                SettingsView(viewModel: infotableViewModel)
                    .navigationBarTitle("Settings", displayMode: .inline)
            default:
                EmptyView()
            }
        }
        .navigationBarTitleDisplayMode(.inline) // Ensure that title is inline, preventing stacking
    }
}

#Preview(){
    ContentView()
        .environmentObject(EnvironmentManager.sampleData) // Inject EnvironmentManager
}

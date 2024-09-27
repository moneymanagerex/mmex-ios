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
    @EnvironmentObject var dataManager: DataManager

    var body: some View {
        ZStack {
            if dataManager.isDatabaseConnected {
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
                    TabContentView(selectedTab: $selectedTab, isDocumentPickerPresented: $isDocumentPickerPresented, isNewDocumentPickerPresented: $isNewDocumentPickerPresented, isSampleDocument: $isSampleDocument)
                }
            } else {
                let infotableViewModel = InfotableViewModel(dataManager: dataManager)
                TabView(selection: $selectedTab) {
                    transactionTab(viewModel: infotableViewModel)
                    insightsTab(viewModel: InsightsViewModel(dataManager: dataManager))
                    addTransactionTab
                    managementTab
                    settingsTab(viewModel: infotableViewModel)
                }
                .onChange(of: selectedTab) { tab in
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
            Image(systemName: "list.bullet")
            Text("Checking")
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
            Image(systemName: "arrow.up.right")
            Text("Insights")
        }
        .tag(1)
    }

    // Add transaction tab
    private var addTransactionTab: some View {
        NavigationView {
            TransactionAddView2(selectedTab: $selectedTab)
                .navigationBarTitle("Add Transaction", displayMode: .inline)
        }
        .tabItem {
            Image(systemName: "plus.circle")
            Text("Add Transaction")
        }
        .tag(2)
    }

    // Management tab
    private var managementTab: some View {
        NavigationView {
            ManagementView(isDocumentPickerPresented: $isDocumentPickerPresented, isNewDocumentPickerPresented: $isNewDocumentPickerPresented, isSampleDocument: $isSampleDocument)
                .navigationBarTitle("Management", displayMode: .inline)
        }
        .tabItem {
            Image(systemName: "folder")
            Text("Management")
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
            Image(systemName: "gearshape")
            Text("Settings")
        }
        .tag(4)
    }

    // File import handling
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let selectedURL = urls.first {
                if selectedURL.startAccessingSecurityScopedResource() {
                    dataManager.openDatabase(at: selectedURL)
                    UserDefaults.standard.set(selectedURL.path, forKey: "SelectedFilePath")
                    selectedURL.stopAccessingSecurityScopedResource()
                } else {
                    print("Unable to access file at URL: \(selectedURL)")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedTab = 0
                }
            }
        case .failure(let error):
            print("Failed to pick a document: \(error.localizedDescription)")
        }
    }

    // File export handling
    private func handleFileExport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            print("Successfully created new document: \(url)")
            if url.startAccessingSecurityScopedResource() {
                dataManager.openDatabase(at: url)
                UserDefaults.standard.set(url.path, forKey: "SelectedFilePath")
                url.stopAccessingSecurityScopedResource()
            } else {
                print("Unable to access file at URL: \(url)")
            }
            let repository = dataManager.repository
            if let tables = Bundle.main.url(forResource: "tables.sql", withExtension: "") {
                repository.execute(url: tables)
                if isSampleDocument { repository.insertSampleData() }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                selectedTab = 0
            }
        case .failure(let error):
            print("Failed to create a new document: \(error.localizedDescription)")
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
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment

    var body: some View {
        // Use @StateObject to manage the lifecycle of InfotableViewModel
        let infotableViewModel = InfotableViewModel(dataManager: dataManager)
        // Here we ensure that there's no additional NavigationStack or NavigationView
        Group {
            switch selectedTab {
            case 0:
                TransactionListView2(viewModel: infotableViewModel) // Summary and Edit feature
                    .navigationBarTitle("Latest Transactions", displayMode: .inline)
            case 1:
                InsightsView(viewModel: InsightsViewModel(dataManager: dataManager))
                    .navigationBarTitle("Reports and Insights", displayMode: .inline)
            case 2:
                TransactionAddView2(selectedTab: $selectedTab)
                    .navigationBarTitle("Add Transaction", displayMode: .inline)
            case 3:
                ManagementView(isDocumentPickerPresented: $isDocumentPickerPresented, isNewDocumentPickerPresented: $isNewDocumentPickerPresented, isSampleDocument: $isSampleDocument)
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
        .environmentObject(DataManager()) // Inject DataManager
}

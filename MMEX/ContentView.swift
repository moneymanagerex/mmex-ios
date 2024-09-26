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
    @State private var isSampleDocumnt = false
    @State private var selectedTab = 0
    @State private var selectedFileURL: URL?
    @State private var isPresentingTransactionAddView = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment

    var body: some View {
        ZStack {
            if let url = selectedFileURL {
                if horizontalSizeClass == .regular {
                    // && verticalSizeClass == .compact {
                    // iPad layout: Tabs on the side
                    NavigationSplitView {
                        SidebarView(selectedTab: $selectedTab)
                    } detail: {
                        TabContentView(selectedTab: $selectedTab, isDocumentPickerPresented: $isDocumentPickerPresented, databaseURL: url)
                    }
                } else {
                    // iPhone layout: Tabs at the bottom
                    TabView(selection: $selectedTab) {
                        // Latest Transactions Tab
                        NavigationView {
                            TransactionListView2(viewModel: InfotableViewModel(databaseURL: url)) // Summary and Edit feature
                                .navigationBarTitle("Latest Transactions", displayMode: .inline)
                        }
                        .tabItem {
                            Image(systemName: "list.bullet")
                            Text("Checking")
                        }
                        .tag(0)

                        // Insights module
                        NavigationView {
                            InsightsView(viewModel: InsightsViewModel(databaseURL: url))
                                .navigationBarTitle("Reports and Insights", displayMode: .inline)
                        }
                        .tabItem {
                            Image(systemName: "arrow.up.right")
                            Text("Insights")
                        }
                        .tag(1)

                        // Add Transactions Tab
                        NavigationView {
                            TransactionAddView2(selectedTab: $selectedTab) // Reuse or new transaction add
                                .navigationBarTitle("Add Transaction", displayMode: .inline)
                        }
                        .tabItem {
                            Image(systemName: "plus.circle")
                            Text("Add Transaction")
                        }
                        .tag(2)

                        // Combined Management Tab
                        NavigationView {
                            ManagementView(isDocumentPickerPresented: $isDocumentPickerPresented)
                                .navigationBarTitle("Management", displayMode: .inline)
                        }
                        .tabItem {
                            Image(systemName: "folder")
                            Text("Management")
                        }
                        .tag(3)

                        // Settings Tab
                        NavigationView {
                            SettingsView(viewModel: InfotableViewModel(databaseURL: url)) // Payees, Accounts, Currency
                                .navigationBarTitle("Settings", displayMode: .inline)
                        }
                        .tabItem {
                            Image(systemName: "gearshape")
                            Text("Settings")
                        }
                        .tag(4)
                    }
                    .onChange(of: selectedTab) { tab in
                        if tab == 2 {
                            isPresentingTransactionAddView = true
                        }
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Button("Open Database") {
                        isDocumentPickerPresented = true
                    }
                    Button("New Database") {
                        isNewDocumentPickerPresented = true
                        isSampleDocumnt = false
                    }
                    Button("Sample Database") {
                        isNewDocumentPickerPresented = true
                        isSampleDocumnt = true
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $isDocumentPickerPresented,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let selectedURL = urls.first {
                    if selectedURL.startAccessingSecurityScopedResource() {
                        selectedFileURL = selectedURL
                        dataManager.openDabase(at: selectedURL)
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
        .fileExporter(
            isPresented: $isNewDocumentPickerPresented,
            document: MMEXDocument(),
            contentType: .mmb,
            defaultFilename: isSampleDocumnt ? "Sample.mmb" : "Untitled.mmb"
        ) { result in
            switch result {
            case .success(let url):
                print("Successfully created new document: \(url)")
                if url.startAccessingSecurityScopedResource() {
                    selectedFileURL = url
                    UserDefaults.standard.set(url.path, forKey: "SelectedFilePath")
                    url.stopAccessingSecurityScopedResource()
                } else {
                    print("Unable to access file at URL: \(url)")
                }
                dataManager.openDabase(at: url)
                let repository = dataManager.getRepository()
                guard let tables = Bundle.main.url(forResource: "tables.sql", withExtension: "") else {
                    print("Cannot find tables.sql in bundle")
                    return
                }
                repository.execute(url: tables)
                if isSampleDocumnt { repository.insertSampleData() }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedTab = 0
                }
            case .failure(let error):
                print("Failed to create a new document: \(error.localizedDescription)")
            }
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
    var databaseURL: URL

    var body: some View {
        // Here we ensure that there's no additional NavigationStack or NavigationView
        Group {
            switch selectedTab {
            case 0:
                TransactionListView2(viewModel: InfotableViewModel(databaseURL: databaseURL)) // Summary and Edit feature
                    .navigationBarTitle("Latest Transactions", displayMode: .inline)
            case 1:
                InsightsView(viewModel: InsightsViewModel(databaseURL: databaseURL))
                    .navigationBarTitle("Reports and Insights", displayMode: .inline)
            case 2:
                TransactionAddView2(selectedTab: $selectedTab)
                    .navigationBarTitle("Add Transaction", displayMode: .inline)
            case 3:
                ManagementView(isDocumentPickerPresented: $isDocumentPickerPresented)
                    .navigationBarTitle("Management", displayMode: .inline)
            case 4:
                SettingsView(viewModel: InfotableViewModel(databaseURL: databaseURL))
                    .navigationBarTitle("Settings", displayMode: .inline)
            default:
                EmptyView()
            }
        }
        .navigationBarTitleDisplayMode(.inline) // Ensure that title is inline, preventing stacking
    }
}

#Preview {
    ContentView()
}

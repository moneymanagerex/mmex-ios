//
//  ContentView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import SwiftUI

struct ContentView: View {
    @State private var isDocumentPickerPresented = false
    @State private var selectedTab = 0

    @State private var selectedFileURL: URL? 
    
    @State private var isPresentingTransactionAddView = false

    init() {
         // Load the stored file URL on app start
         // if let savedURL = UserDefaults.standard.url(forKey: "selectedFileURL") {
         //   _selectedFileURL = State(initialValue: savedURL)
         // }
    }

    var body: some View {
        NavigationStack {
            if let url = selectedFileURL {
                TabView (selection: $selectedTab) {
                    // Latest Transactions Tab
                    NavigationView {
                        TransactionListView2(databaseURL: url) // Summary and Edit feature
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
                        TransactionAddView2(databaseURL: url, selectedTab: $selectedTab) // Reuse or new transaction add
                            .navigationBarTitle("Add Transaction", displayMode: .inline)
                    }
                    .tabItem {
                        Image(systemName: "plus.circle")
                        Text("Add Transaction")
                    }
                    .tag(2)
                    
                    // Combined Management Tab
                    NavigationView {
                        ManagementView(databaseURL: url, isDocumentPickerPresented: $isDocumentPickerPresented)
                            .navigationBarTitle("Management", displayMode: .inline)
                    }
                    .tabItem {
                        Image(systemName: "folder")
                        Text("Management")
                    }
                    .tag(3)
                    
                    // Settings Tab
                    NavigationView {
                        SettingsView(databaseURL: url) // Payees, Accounts, Currency
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
            } else {
                
                Button("Open Database") {
                    // Trigger the file picker
                    isDocumentPickerPresented = true
                }
            }
        }
        .fileImporter(
            isPresented: $isDocumentPickerPresented, // Toggle state for presentation
            allowedContentTypes: [.item], // Allowed types, you can customize it
            allowsMultipleSelection: false // Single file selection
        ) { result in
            switch result {
            case .success(let urls):
                if let selectedURL = urls.first {
                    // Handle security-scoped resource access
                    if selectedURL.startAccessingSecurityScopedResource() {
                        selectedFileURL = selectedURL

                        // Save the file path for later access
                        UserDefaults.standard.set(selectedURL.path, forKey: "SelectedFilePath")

                        selectedURL.stopAccessingSecurityScopedResource() // Stop when done
                    } else {
                        print("Unable to access file at URL: \(selectedURL)")
                    }

                    // Navigate back to the first tab with delay to ensure data is loaded
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        selectedTab = 0
                    }
                }
            case .failure(let error):
                print("Failed to pick a document: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}

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
        //    _selectedFileURL = State(initialValue: savedURL)
        //}
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
                    
                    // Re-open Database Tab
                    NavigationView {
                        VStack {
                            Button("Re-open Database") {
                                isDocumentPickerPresented = true
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .navigationBarTitle("Re-open Database", displayMode: .inline)
                    }
                    .tabItem {
                        Image(systemName: "folder")
                        Text("Re-open")
                    }
                    .tag(3) // Tag for the Re-open Database tab
                    
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
        .sheet(isPresented: $isDocumentPickerPresented, onDismiss: {
            // Navigate back to the landing page after selecting the new database
            if selectedFileURL != nil {
                // Delay before switching back to tag(0) to ensure data is loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedTab = 0 // Navigate back to the first tab
                }
            }
        }) {
            DocumentPicker(selectedFileURL: $selectedFileURL)
        }
        .onChange(of: selectedFileURL) { newURL in
            // Save the selected file URL to UserDefaults when it's set
             if let url = newURL {
                UserDefaults.standard.set(url.absoluteString, forKey: "selectedFileURL")
             }
        }
    }
}

#Preview {
    ContentView()
}

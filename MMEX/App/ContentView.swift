//
//  ContentView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @State private var isDocumentPickerPresented = false
    @State private var isNewDocumentPickerPresented = false
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

    var body: some View {
        ZStack {
            if vm.isDatabaseConnected {
                connectedView
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
                    selectedTab: $selectedTab,
                    isDocumentPickerPresented: $isDocumentPickerPresented,
                    isNewDocumentPickerPresented: $isNewDocumentPickerPresented,
                    isAttachDocumentPickerPresented: $isAttachDocumentPickerPresented,
                    isSampleDocument: $isSampleDocument
                )
            }
        } else {
            TabView(selection: $selectedTab) {
                journalTab()
                insightsTab()
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
                vm.createDatabase(at: nil, sampleData: true)
                guard vm.isDatabaseConnected else { return }
                log.info("Successfully created sample database in memory")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedTab = Preference.selectedTab
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
                isNewDocumentPickerPresented: $isNewDocumentPickerPresented,
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
                    selectedTab = Preference.selectedTab
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
    
    // File export handling
    private func handleFileExport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            vm.createDatabase(at: url, sampleData: isSampleDocument)
            guard vm.isDatabaseConnected else { return }
            log.info("Successfully created database: \(url)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                selectedTab = Preference.selectedTab
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
                Label("Journal", systemImage: "list.bullet")
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
                JournalView() // Summary and Edit feature
                    .navigationBarTitle("Journal", displayMode: .inline)
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

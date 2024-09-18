//
//  SettingsView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct SettingsView: View {
    let databaseURL: URL

    var body: some View {
        List {
            // Section: App Information
            Section(header: Text("App Information")) {
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
            
            // Section: Support and Help
            Section(header: Text("Support and Help")) {
                NavigationLink(destination: HelpFAQView()) {
                    Text("Help / FAQ")
                }
                NavigationLink(destination: ContactSupportView()) {
                    Text("Contact Support")
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView(databaseURL: URL(string: "path/to/database")!)
}

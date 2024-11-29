//
//  HelpFAQView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct HelpFAQView: View {
    var body: some View {
        List {
            Section(header: Text("General")) {
                Text("How to add a transaction?")
                Text("How to manage categories?")
            }
            
            Section(header: Text("Advanced")) {
                Text("How to import/export data?")
                Text("How to generate reports?")
            }
        }
        .navigationTitle("Help / FAQ")
    }
}

#Preview {
    NavigationView {
        HelpFAQView(
        )
        .navigationBarTitle("Settings", displayMode: .inline)
    }
}

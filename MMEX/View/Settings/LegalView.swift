//
//  LegalView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct LegalView: View {
    var body: some View {
        List {
            Section(header: Text("Legal Documents")) {
                NavigationLink(destination: LegalTermsView()
                    .navigationTitle("Terms of Service")
                ) {
                    Text("Terms of Service")
                }
                NavigationLink(destination: LegalPrivacyView()
                    .navigationTitle("Privacy Policy")
                ) {
                    Text("Privacy Policy")
                }
            }
        }
    }
}

#Preview {
    MMEXPreview.settings("Legal") { pref, vm in
        LegalView()
    }
}

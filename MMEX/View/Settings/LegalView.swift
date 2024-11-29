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
                NavigationLink(destination: TermsOfServiceView()) {
                    Text("Terms of Service")
                }
                NavigationLink(destination: PrivacyPolicyView()) {
                    Text("Privacy Policy")
                }
            }
        }
        .navigationTitle("Legal")
    }
}

#Preview {
    NavigationView {
        LegalView(
        )
        .navigationBarTitle("Settings", displayMode: .inline)
    }
}

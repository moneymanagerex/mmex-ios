//
//  LegalTermsView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct LegalTermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Last updated: September 18, 2024")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("These Terms of Service govern your use of our app. By using the app, you agree to comply with and be bound by these terms.")
                    .padding(.top)
                
                // Sample terms content
                Text("1. Use of the App")
                    .font(.headline)
                
                Text("You must use the app in compliance with all applicable laws. Any misuse or illegal activities related to the app may result in termination of your access.")
                
                Text("2. Content Ownership")
                    .font(.headline)
                
                Text("All content provided by the app is owned by the app developers or its licensors. You are not allowed to copy, reproduce, or distribute any content without permission.")
                
                // Add more sections as needed...
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    MMEXPreview.settings("Terms of Service") { pref, vm in
        LegalTermsView()
    }
}

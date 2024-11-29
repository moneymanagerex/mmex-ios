//
//  PrivacyPolicyView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Last updated: September 18, 2024")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("This Privacy Policy outlines how we handle your personal information while using the app.")
                    .padding(.top)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

#Preview {
    NavigationView {
        PrivacyPolicyView(
        )
        .navigationTitle("Legal")
        .navigationBarTitle("Settings", displayMode: .inline)
    }
}

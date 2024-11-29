//
//  LegalPrivacyView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct LegalPrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Last updated: September 18, 2024")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("This Privacy Policy outlines how we handle your personal information while using the app.")
                    .padding(.top)

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    MMEXPreview.settings("Privacy Policy") { pref, vm in
        LegalPrivacyView()
    }
}

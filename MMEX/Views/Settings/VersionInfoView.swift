//
//  VersionInfoView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct VersionInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("App Version")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Version 1.0.0")
            
            Text("Release Notes")
                .font(.headline)
            
            Text("• Initial release with transaction tracking, insights, and account management.\n• Bug fixes and improvements.")
            
            Spacer()
        }
        .padding()
        .navigationTitle("Version Info")
    }
}

#Preview {
    VersionInfoView()
}

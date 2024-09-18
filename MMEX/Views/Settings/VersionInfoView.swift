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
            Text("Version")
                .font(.title)
                .fontWeight(.bold)
            Text(appVersion)
            
            Text("Build")
                .font(.title)
                .fontWeight(.bold)
            Text(appBuild)
            
            Text("Release Notes")
                .font(.headline)
            
            Text("• Initial release with transaction tracking, insights, and account management.\n• Bug fixes and improvements.")
            
            Spacer()
        }
        .padding()
        .navigationTitle("Version Info")
    }

    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }

    var appBuild: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
    }
}

#Preview {
    VersionInfoView()
}

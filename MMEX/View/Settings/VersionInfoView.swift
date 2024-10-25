//
//  VersionInfoView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct VersionInfoView: View {
    @State private var releaseNotes: String = "Loading..."
    @State private var errorMessage: String?
    @State private var isLoading: Bool = true

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
            
            if isLoading {
                ProgressView()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                if let attributedString = try? AttributedString(markdown: releaseNotes) {
                    Text(attributedString)
                        .padding()
                } else {
                    Text("Failed to render release notes.")
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Version Info")
        .onAppear {
            Task {
                await fetchReleaseNotes()
            }
        }
    }

    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }

    var appBuild: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
    }

    private func fetchReleaseNotes() async {
        let urlString = "https://api.github.com/repos/moneymanagerex/mmex-ios/releases/tags/\(appVersion)"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let body = json["body"] as? String {
                DispatchQueue.main.async {
                    self.releaseNotes = body
                    self.isLoading = false
                }
            } else {
                errorMessage = "Invalid response format"
                isLoading = false
            }
        } catch {
            errorMessage = "Error fetching release notes: \(error.localizedDescription)"
            isLoading = false
        }
    }
}

#Preview {
    VersionInfoView()
}

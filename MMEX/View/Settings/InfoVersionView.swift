//
//  InfoVersionView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct InfoVersionView: View {
    var appVersion: String? = Self.appVersion
    var appBuild: String? = Self.appBuild
    @State private var releaseNotes: String = "Loading..."
    @State private var errorMessage: String?
    @State private var isLoading: Bool = true

    var body: some View {
        List {
            Section {
                ItemTheme.settings(
                    nameView: { Text("Version") },
                    infoView: { Text(appVersion ?? "N/A") }
                )
                ItemTheme.settings(
                    nameView: { Text("Build") },
                    infoView: { Text(appBuild ?? "N/A") }
                )
            }
       
            Section("Release Notes") {
                if isLoading {
                    ProgressView()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                } else {
                    // Attempt to render the markdown
                    if let attributedString = try? AttributedString(markdown: releaseNotes, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                        Text(attributedString)
                            .padding()
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("Failed to render release notes.")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .listSectionSpacing(10)

        .task {
            await fetchReleaseNotes()
        }
    }

    static var appVersion: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    static var appBuild: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }

    static var appVersionBuild: String? {
        if let appVersion = Self.appVersion, let appBuild = Self.appBuild {
            "\(appVersion) (\(appBuild))"
        } else if let appVersion = Self.appVersion {
            "\(appVersion)"
        } else {
            nil
        }
    }

    private func fetchReleaseNotes() async {
        if let appVersion {
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
        } else {
            errorMessage = "Unknown version"
            isLoading = false
        }
    }
}

#Preview {
    MMEXPreview.settings("Version") { pref, vm in
        InfoVersionView(
            appVersion: "0.1.20",
            appBuild: "26"
        )
    }
}

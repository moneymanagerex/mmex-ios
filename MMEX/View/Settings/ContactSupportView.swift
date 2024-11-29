//
//  ContactSupportView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

import SwiftUI

struct ContactSupportView: View {
    var body: some View {
        List {
            Section(header: Text("Contact Support")) {
                // Link to the official website
                Link(destination: URL(string: "https://moneymanagerex.org/")!) {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                        Text("Visit Official Website")
                    }
                }
                
                // Link to email support
                Link(destination: URL(string: "mailto:support@moneymanagerex.org")!) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.green)
                        Text("Email Support")
                    }
                }
                
                // Link to the forum
                Link(destination: URL(string: "https://forum.moneymanagerex.org/")!) {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.orange)
                        Text("User Forum")
                    }
                }
                
                // Option to report an issue
                Link(destination: URL(string: "https://github.com/moneymanagerex/moneymanagerex/issues")!) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text("Report an Issue")
                    }
                }
            }
            
            Section(header: Text("Social Media")) {
                // Social media links
                Link(destination: URL(string: "https://www.facebook.com/moneymanagerex/")!) {
                    HStack {
                        Image(systemName: "logo.facebook")
                            .foregroundColor(.blue)
                        Text("Facebook")
                    }
                }
                
                Link(destination: URL(string: "https://twitter.com/moneymanagerex")!) {
                    HStack {
                        Image(systemName: "logo.twitter")
                            .foregroundColor(.blue)
                        Text("Twitter")
                    }
                }
            }
        }
        .navigationTitle("Contact Support")
    }
}

#Preview {
    NavigationView {
        ContactSupportView(
        )
        .navigationBarTitle("Settings", displayMode: .inline)
    }
}

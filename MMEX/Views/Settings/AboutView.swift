//
//  AboutView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("About This App")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("This app helps you manage your finances efficiently by tracking transactions, accounts, and generating insights.")
            
            Text("Credits")
                .font(.headline)
            
            Text("Developed by XYZ Developer")
            Text("Special thanks to all open-source contributors!")
            
            Spacer()
        }
        .padding()
        .navigationTitle("About")
    }
}

#Preview {
    AboutView()
}

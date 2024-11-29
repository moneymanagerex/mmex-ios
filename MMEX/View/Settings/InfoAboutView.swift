//
//  InfoAboutView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct InfoAboutView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("MMEX4iOS")
                .font(.title)
                .fontWeight(.bold)
            
            Text("This app helps you manage your finances efficiently by tracking transactions, accounts, and generating insights.")
            
            Text("Credits")
                .font(.headline)
            
            Text("Developed by Lisheng Guan, George Ef")
            Text("Special thanks to all open-source contributors!")
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    MMEXPreview.settings("About") { pref, vm in
        InfoAboutView()
    }
}

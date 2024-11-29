//
//  InfoHelpView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/18.
//

import SwiftUI

struct InfoHelpView: View {
    var body: some View {
        List {
            Section(header: Text("General")) {
                Text("How to add a transaction?")
                Text("How to manage categories?")
            }
            
            Section(header: Text("Advanced")) {
                Text("How to import/export data?")
                Text("How to generate reports?")
            }
        }
    }
}

#Preview {
    MMEXPreview.settings("Help") { pref, vm in
        InfoHelpView()
    }
}

//
//  MMEXApp.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import SwiftUI

@main
struct MMEXApp: App {
    @StateObject private var dataManager = DataManager(withStoredDatabase: ())

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}

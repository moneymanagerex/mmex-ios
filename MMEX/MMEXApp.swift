//
//  MMEXApp.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import SwiftUI
import OSLog

let log = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "mmex.log"
)

@main
struct MMEXApp: App {
    @StateObject private var env = EnvironmentManager(withStoredDatabase: ())

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(env)
        }
    }
}

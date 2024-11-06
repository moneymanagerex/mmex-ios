//
//  MMEXApp.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import SwiftUI
import OSLog
import Amplitude

let log = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "mmex.log"
)

@main
struct MMEXApp: App {
    @StateObject private var env = EnvironmentManager(withStoredDatabase: ())

    @AppStorage("isTrackingEnabled") private var isTrackingEnabled: Bool = false // Default is tracking disabled
    @AppStorage("userID") private var userID: String = "" // Store user ID in AppStorage

    init() {
        if userID.isEmpty {
            userID = String(format: "ios_%@", TimestampString(Date()).string)
        }
        if isTrackingEnabled {
            Amplitude.instance().defaultTracking = AMPDefaultTrackingOptions.initWithSessions(true, appLifecycles: true, deepLinks: false, screenViews: false);
            Amplitude.instance().initializeApiKey("1e1fbc10354400d9c3392a89558d693d")
            Amplitude.instance().setUserId(userID) // copy from/to Infotable.UID
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(env: env)
                .environmentObject(env)
                .onAppear {
                    let appearance: Int = UserDefaults.standard.integer(forKey: "appearance")
                    Appearance.apply(appearance)
                }
        }
    }
}

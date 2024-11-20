//
//  MMEXApp.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import OSLog
import SwiftUI
import Amplitude

let log = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "mmex.log"
)

@main
struct MMEXApp: App {
    @StateObject private var env = EnvironmentManager(withStoredDatabase: ())

    func track(env: EnvironmentManager) {
        log.debug("DEBUG: MMEXApp.track()")
        if env.track.userId.isEmpty {
            env.track.userId = String(format: "ios_%@", TimestampString(Date()).string)
        }

        if env.track.sendUsage == .boolTrue {
            Amplitude.instance().defaultTracking = AMPDefaultTrackingOptions.initWithSessions(
                true, appLifecycles: true, deepLinks: false, screenViews: false
            )
            Amplitude.instance().initializeApiKey("1e1fbc10354400d9c3392a89558d693d")
            Amplitude.instance().setUserId(env.track.userId) // copy from/to Infotable.UID
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(env: env)
                .onAppear {
                    env.theme.appearance.apply()
                    track(env: env)
                }
                .environmentObject(env)
        }
    }
}

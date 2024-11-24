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
    @StateObject private var pref = Preference()
    @StateObject private var vm = ViewModel(withStoredDatabase: ())

    func track(pref: Preference) {
        log.debug("DEBUG: MMEXApp.track()")
        if pref.track.userId.isEmpty {
            pref.track.userId = String(format: "ios_%@", TimestampString(Date()).string)
        }

        if pref.track.sendUsage == .boolTrue {
            Amplitude.instance().defaultTracking = AMPDefaultTrackingOptions.initWithSessions(
                true, appLifecycles: true, deepLinks: false, screenViews: false
            )
            Amplitude.instance().initializeApiKey("1e1fbc10354400d9c3392a89558d693d")
            Amplitude.instance().setUserId(pref.track.userId) // copy from/to Infotable.UID
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    pref.theme.appearance.apply()
                    track(pref: pref)
                }
                .environmentObject(pref)
                .environmentObject(vm)
        }
    }
}

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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var pref = Preference()
    @StateObject private var vm = ViewModel(withStoredDatabase: ())

    func track(pref: Preference) {
        log.debug("DEBUG: MMEXApp.track()")
        if pref.track.userId.isEmpty {
            pref.track.userId = String(format: "ios_%@", TimestampString(Date()).string)
        }

        if pref.track.sendUsage == .boolTrue {
            Amplitude.instance().setUserId(pref.track.userId) // copy from/to Infotable.UID
            Amplitude.instance().defaultTracking = AMPDefaultTrackingOptions.initWithSessions(
                true, appLifecycles: true, deepLinks: false, screenViews: false
            )
            Amplitude.instance().initializeApiKey("1e1fbc10354400d9c3392a89558d693d")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    pref.theme.appearance.apply()
                    track(pref: pref)
                }
                .handlesExternalEvents(preferring: Set(["mmb"]), allowing: Set(["*"]))
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("MMEXOpenFile"))) { notification in
                    log.debug("DEBUG: onReceive")
                    if let url = notification.object as? URL {
                        log.debug("File URL received in SwiftUI: \(url.path)")
                        // vm.openDatabase(at: url) // Example: Replace with your actual ViewModel logic
                    }
                }
                .environmentObject(pref)
                .environmentObject(vm)
        }
    }
}

@MainActor
struct MMEXPreview {
    static let pref = Preference()
    static let vmWithoutData    = ViewModel.withoutData
    static let vmWithSampleData = ViewModel.withSampleData

    @ViewBuilder
    static func appWithoutData<Content: View>(
        @ViewBuilder content: @escaping (_ pref: Preference, _ vm: ViewModel) -> Content
    ) -> some View {
        content(Self.pref, Self.vmWithoutData)
            .environmentObject(Self.pref)
            .environmentObject(Self.vmWithoutData)
    }

    @ViewBuilder
    static func appWithSampleData<Content: View>(
        @ViewBuilder content: @escaping (_ pref: Preference, _ vm: ViewModel) -> Content
    ) -> some View {
        content(Self.pref, Self.vmWithSampleData)
            .environmentObject(Self.pref)
            .environmentObject(Self.vmWithSampleData)
    }
}

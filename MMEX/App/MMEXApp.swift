//
//  MMEXApp.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import OSLog
import SwiftUI

let log = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "mmex.log"
)

@main
struct MMEXApp: App {
    @StateObject private var pref = Preference()
    @StateObject private var vm = ViewModel(withStoredDatabase: ())
    @StateObject private var appContext = AppContext.shared
    @StateObject private var journalViewModel = JournalViewModel()

    func track(pref: Preference) {
        log.debug("DEBUG: MMEXApp.track()")
        if pref.track.userId.isEmpty {
            pref.track.userId = String(format: "ios_%@", TimestampString(Date()).string)
        }

        if pref.track.sendUsage == .boolTrue {
            // TODO?
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
                .environmentObject(appContext)
                .environmentObject(journalViewModel)
        }
    }
}

@MainActor
struct MMEXPreview {
    static let pref = Preference()
    static let vmWithoutData    = ViewModel.withoutData
    static let vmWithSampleData = ViewModel.withSampleData
    static let journalViewModel = JournalViewModel()

    @ViewBuilder
    static func appWithoutData<Content: View>(
        @ViewBuilder content: @escaping (_ pref: Preference, _ vm: ViewModel) -> Content
    ) -> some View {
        content(Self.pref, Self.vmWithoutData)
            .environmentObject(Self.pref)
            .environmentObject(Self.vmWithoutData)
            .environmentObject(AppContext.shared)
            .environmentObject(Self.journalViewModel)
    }

    @ViewBuilder
    static func appWithSampleData<Content: View>(
        @ViewBuilder content: @escaping (_ pref: Preference, _ vm: ViewModel) -> Content
    ) -> some View {
        content(Self.pref, Self.vmWithSampleData)
            .environmentObject(Self.pref)
            .environmentObject(Self.vmWithSampleData)
            .environmentObject(AppContext.shared)
            .environmentObject(Self.journalViewModel)
    }
}

//
//  Preference.swift
//  MMEX
//
//  2024-11-23: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

class Preference: ObservableObject {
    @Published var theme : Theme           = .init(prefix: "theme.")
    @Published var enter : EnterPreference = .init(prefix: "enter.")
    @Published var track : TrackPreference = .init(prefix: "track.")

    static let selectedTab = 1
}

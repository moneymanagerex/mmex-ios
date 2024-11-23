//
//  TrackPreference.swift
//  MMEX
//
//  2024-11-15: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

struct TrackPreference {
    @StoredPreference var userId    : String   = ""
    @StoredPreference var sendUsage : BoolEnum = .boolTrue
}

extension TrackPreference {
    init(prefix: String?) {
        self.$userId    = prefix?.appending("userId")
        self.$sendUsage = prefix?.appending("sendUsage")
    }
}

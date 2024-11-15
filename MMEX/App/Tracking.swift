//
//  Tracking.swift
//  MMEX
//
//  2024-11-15: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

struct Tracking {
    @Preference var userId    : String   = ""
    @Preference var sendUsage : BoolEnum = .boolTrue
}

extension Tracking {
    init(prefix: String?) {
        self.$userId    = prefix?.appending("userId")
        self.$sendUsage = prefix?.appending("sendUsage")
    }
}

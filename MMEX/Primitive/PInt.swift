//
//  PInt.swift
//  MMEX
//
//  2024-11-28: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

// positive integer
struct PInt: Identifiable, Comparable, Hashable, Copyable, Sendable, Codable {
    private(set) var value: Int = 1

    init() {
    }

    init?(exactly value: Int) {
        if value > 0 { self.value = value } else { return nil }
    }

    // non-positive value is silently mapped to 1
    init(clamping value: Int) {
        if value > 0 { self.value = value }
    }

    var id: Int { value }
    
    static func <(lhs: Self, rhs: Self) -> Bool {
        lhs.value < rhs.value
    }
}

extension PInt: LosslessStringConvertible {
    var description: String {
        self.value.description
    }

    init?(_ valueDescription: String) {
        if let value = Int(valueDescription) {
            self.init(exactly: value)
        } else {
            return nil
        }
    }
}

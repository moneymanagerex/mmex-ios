//
//  PIntInf.swift
//  MMEX
//
//  2024-11-28: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

// positive integer or infinity
struct PIntInf: Identifiable, Comparable, Hashable, Copyable, Sendable, Codable {
    private(set) var value: Int = 1

    init() {
    }
    
    init(inf: Void) {
        self.value = -1
    }

    init?(exactly value: Int) {
        if value > 0 { self.value = value } else { return nil }
    }

    // non-positive value is silently mapped to 1
    init(clamping value: Int) {
        if value > 0 { self.value = value }
    }

    static let inf: Self = .init(inf: ())
    var isInf: Bool { value == -1 }

    var id: Int { value }

    static func <(lhs: Self, rhs: Self) -> Bool {
        !lhs.isInf && (rhs.isInf || lhs.value < rhs.value)
    }
}

extension PIntInf: LosslessStringConvertible {
    var description: String {
        isInf ? "Inf" : self.value.description
    }

    init?(_ valueDescription: String) {
        if valueDescription == "Inf" {
            self.init(inf: ())
        } else if let value = Int(valueDescription) {
            self.init(exactly: value)
        } else {
            return nil
        }
    }
}

extension PIntInf {
    var inc: Self {
        isInf ? Self.inf : .init(clamping: self.value + 1)
    }

    var dec: Self? {
        isInf ? Self.inf : .init(exactly: self.value - 1)
    }
}

//
//  PIntInf.swift
//  MMEX
//
//  2024-11-26: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

struct PIntInf: Identifiable, Equatable, Hashable, Copyable, Sendable, Codable {
    private(set) var value: Int = -1

    init() {
    }

    // non-positive value is silently mapped to -1 (Inf)
    init(_ value: Int) {
        if value > 0 { self.value = value }
    }

    static let inf: Self = .init(-1)

    var isInf: Bool { value <= 0 }
    var id: Int { value }
}

extension PIntInf: ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = Int
    
    init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension PIntInf: LosslessStringConvertible {
    var description: String {
        isInf ? "Inf" : self.value.description
    }

    init?(_ valueDescription: String) {
        if valueDescription == "Inf" {
            self.init(-1)
        } else if let value = Int(valueDescription), value > 0 {
            self.init(value)
        } else {
            return nil
        }
    }
}

//
//  PInt.swift
//  MMEX
//
//  2024-11-26: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

struct PInt: Identifiable, Equatable, Hashable, Copyable, Sendable, Codable {
    private(set) var value: Int = 1

    init() {
    }

    // non-positive value is silently mapped to 1
    init(_ value: Int) {
        if value > 0 { self.value = value }
    }

    static let void: Self = .init()

    var id: Int { value }
}

extension PInt: ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = Int
    
    init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension PInt: LosslessStringConvertible {
    var description: String {
        self.value.description
    }

    init?(_ valueDescription: String) {
        if let value = Int(valueDescription), value > 0 {
            self.init(value)
        } else {
            return nil
        }
    }
}

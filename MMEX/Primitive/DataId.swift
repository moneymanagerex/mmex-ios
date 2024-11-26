//
//  DataId.swift
//  MMEX
//
//  2024-09-22: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

struct DataId: Identifiable, Equatable, Hashable, Copyable, Sendable, Codable {
    private(set) var value: Int = -1

    init() {
    }

    // non-positive value is silently mapped to -1
    init(_ value: Int) {
        if value > 0 { self.value = value }
    }

    static let void: Self = .init()

    var isVoid: Bool { value <= 0 }
    var id: Int { value }
}

extension DataId: ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = Int
    
    init(integerLiteral value: Int) {
        self.init(value)
    }
    
    init(_ value: Int64) {
        self.init(Int(value))
    }
}

extension DataId: LosslessStringConvertible {
    var description: String {
        self.value.description
    }

    init?(_ valueDescription: String) {
        if let value = Int(valueDescription) {
            self.init(value)
        } else {
            return nil
        }
    }
}

// MARK: - Custom Codable Implementation
extension DataId {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value: Int = try container.decode(Int.self)
        self.init(value)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

extension Int64 {
    init(_ dataId: DataId) {
        self = Int64(dataId.value)
    }
}

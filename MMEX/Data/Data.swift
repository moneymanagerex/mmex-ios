//
//  Data.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation

struct DataId: Identifiable, Equatable, Hashable, Copyable, Sendable, Codable {
    private(set) var value: Int = -1

    init() {
    }

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

extension Int64 {
    init(_ dataId: DataId) {
        self = Int64(dataId.value)
    }
}

protocol DataProtocol: ExportableEntity {
    static var dataName: (String, String) { get }

    var id: DataId { get set }
    func shortDesc() -> String
}

protocol EnumCollateNoCase: RawRepresentable, CaseIterable, Identifiable, Codable
    where RawValue == String
{
    static var defaultValue: Self { get }
}

extension EnumCollateNoCase {
    init(collateNoCase name: String?) {
        guard let name else { self = Self.defaultValue; return }
        switch Self.allCases.first(where: {
            $0.rawValue.caseInsensitiveCompare(name) == .orderedSame
        } ) {
        case .some(let x): self = x
        default: self = Self.defaultValue
        }
    }

    var id: String { self.rawValue }
    var name: String { rawValue.capitalized }
}

extension Int {
    var defaultZero: Int? {
        get { self }
        set { self = newValue ?? 0 }
    }

    var defaultOne: Int? {
        get { self }
        set { self = newValue ?? 1 }
    }
}

extension Double {
    var defaultZero: Double? {
        get { self }
        set { self = newValue ?? 0.0 }
    }

    var defaultOne: Double? {
        get { self }
        set { self = newValue ?? 1.0 }
    }
}

protocol DateStringProtocal: Codable {
    var string  : String { get set }
    static var formatter: DateFormatter { get }
    init(string: String)
}

extension DateStringProtocal {
    init(_ string: String) {
        self.init(string: string)
    }

    init(_ date: Date) {
        self.init(string: Self.dateToString(date))
    }

    init(_ optDate: Date?) {
        self.init(string: Self.optDateToString(optDate))
    }

    static func dateToString(_ date: Date) -> String {
        Self.formatter.string(from: date)
    }

    static func optDateToString(_ optDate: Date?) -> String {
        if let date = optDate { dateToString(date) } else { "" }
    }

    static func stringToOptDate(_ string: String) -> Date? {
        if !string.isEmpty { Self.formatter.date(from: string) } else { nil }
    }

    static func stringToDate(_ string: String) -> Date {
        stringToOptDate(string) ?? Date()
    }

    var date: Date {
        get { Self.stringToDate(self.string) }
        set { self.string = Self.dateToString(newValue) }
    }
    var optDate: Date? {
        get { Self.stringToOptDate(self.string) }
        set { self.string = Self.optDateToString(newValue) }
    }
}

struct DateString: DateStringProtocal {
    var string: String

    static var formatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }
}

struct DateTimeString: DateStringProtocal {
    var string: String

    static var formatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return df
    }
}

struct TimestampString: DateStringProtocal {
    var string: String

    static var formatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmssSSS"
        return df
    }
}

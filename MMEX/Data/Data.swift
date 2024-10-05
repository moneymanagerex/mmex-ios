//
//  ModelProtocal.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation

protocol DataProtocol {
    static var dataName: String { get }

    var id: Int64 { get set }
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

struct DateString: Codable {
    var string: String

    init(_ string: String) {
        self.string = string
    }

    static var formatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }

    var stringOrDash: String {
        !self.string.isEmpty ? self.string : "-"
    }

    var date: Date {
        get { Self.formatter.date(from: self.string) ?? Date() }
        set { self.string = Self.formatter.string(from: newValue) }
    }
}

struct DateTimeString: Codable {
    var string: String

    init(_ string: String) {
        self.string = string
    }

    static var formatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return df
    }

    var stringOrDash: String {
        !self.string.isEmpty ? self.string : "-"
    }

    var date: Date {
        get { Self.formatter.date(from: self.string) ?? DateString.formatter.date(from: self.string) ?? Date() }
        set { self.string = Self.formatter.string(from: newValue) }
    }
}

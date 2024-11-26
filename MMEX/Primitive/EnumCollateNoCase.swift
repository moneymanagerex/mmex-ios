//
//  EnumCollateNoCase.swift
//  MMEX
//
//  2024-09-22: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

protocol EnumCollateNoCase: RawRepresentable, CaseIterable, Identifiable, Codable, LosslessStringConvertible
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

extension EnumCollateNoCase {
    var description: String {
        self.rawValue
    }

    init(_ valueDescription: String) {
        self = Self(collateNoCase: valueDescription)
    }
}

enum BoolEnum: String, EnumCollateNoCase {
    case boolFalse = "FALSE"
    case boolTrue  = "TRUE"
    static let defaultValue = Self.boolFalse
    
    var asBool: Bool {
        get { self == .boolTrue }
        set { self = newValue ? .boolTrue : .boolFalse }
    }
}

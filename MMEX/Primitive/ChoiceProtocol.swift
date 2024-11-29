//
//  ChoiceProtocol.swift
//  MMEX
//
//  2024-09-22: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

protocol ChoiceProtocol: RawRepresentable, CaseIterable, Identifiable, Codable, LosslessStringConvertible
    where RawValue == String
{
    static var defaultValue: Self { get }
}

extension ChoiceProtocol {
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

extension ChoiceProtocol {
    var description: String {
        self.rawValue
    }

    init(_ valueDescription: String) {
        self = Self(collateNoCase: valueDescription)
    }
}

enum BoolChoice: String, ChoiceProtocol {
    case boolFalse = "FALSE"
    case boolTrue  = "TRUE"
    static let defaultValue = Self.boolFalse
    
    var asBool: Bool {
        get { self == .boolTrue }
        set { self = newValue ? .boolTrue : .boolFalse }
    }
}

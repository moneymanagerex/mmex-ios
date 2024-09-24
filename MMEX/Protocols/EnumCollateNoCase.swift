//
//  EnumCollateNoCase.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation

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

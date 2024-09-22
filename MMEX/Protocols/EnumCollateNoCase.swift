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
    init?(collateNoCase name: String?)
    var id: String { get }
    var name: String { get }
}

extension EnumCollateNoCase {
    init?(collateNoCase name: String?) {
        guard let name else { return nil }
        switch Self.allCases.first(where: {
            $0.rawValue.caseInsensitiveCompare(name) == .orderedSame
        } ) {
        case .some(let x): self = x
        default: return nil
        }
    }

    var id: String { self.rawValue }
    var name: String { rawValue.capitalized }
}

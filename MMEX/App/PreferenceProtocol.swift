//
//  PreferenceProtocol.swift
//  MMEX
//
//  2024-11-15: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

protocol PreferenceProtocol: EnumCollateNoCase {
    static var preferenceKey: String { get }
}

extension PreferenceProtocol {
    static func loadPreference() -> Self {
        let value = Self(collateNoCase: UserDefaults.standard.string(forKey: Self.preferenceKey))
        log.debug("DEBUG: PreferenceProtocol.loadPreference(\(Self.preferenceKey)): \(value.rawValue))")
        return value
    }

    func savePreference() {
        log.debug("DEBUG: PreferenceProtocol.savePreference(\(Self.preferenceKey), \(self.rawValue))")
        UserDefaults.standard.set(self.rawValue, forKey: Self.preferenceKey)
    }
}

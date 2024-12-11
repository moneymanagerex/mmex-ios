//
//  StoredPreferenceDictionary.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/12/11.
//

import Foundation

@propertyWrapper
struct StoredPreferenceDictionary {
    private var key: String
    private var dictionary: [String: String]

    var wrappedValue: [String: String] {
        get { dictionary }
        set {
            dictionary = newValue
            save(dictionary)
        }
    }

    var projectedValue: Self { self }

    init(key: String) {
        self.key = key
        self.dictionary = UserDefaults.standard.dictionary(forKey: key) as? [String: String] ?? [:]
    }

    func get(forKey key: String) -> String? {
        dictionary[key]
    }

    mutating func set(_ value: String, forKey key: String) {
        dictionary[key] = value
        save(dictionary)
    }

    mutating func remove(forKey key: String) {
        dictionary.removeValue(forKey: key)
        save(dictionary)
    }

    private func save(_ dictionary: [String: String]) {
        UserDefaults.standard.set(dictionary, forKey: key)
    }
}

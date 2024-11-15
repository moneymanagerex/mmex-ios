//
//  Preferences.swift
//  MMEX
//
//  2024-11-15: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

@propertyWrapper
struct Preference<ValueType: LosslessStringConvertible> {
    private var key: String?
    private var value: ValueType
    private let initValue: ValueType

    var projectedValue: String? {
        get { key }
        set {
            key = newValue
            if let key, let stringValue = Self.load(key: key) {
                value = ValueType(stringValue) ?? initValue
            } else {
                value = initValue
            }
        }
    }

    var wrappedValue: ValueType {
        get { value }
        set {
            value = newValue
            if let key {
                Self.save(key: key, value: value.description)
            }
        }
    }

    init(key: String? = nil, wrappedValue initValue: ValueType) {
        self.key = key
        self.initValue = initValue
        if let key, let stringValue = Self.load(key: key) {
            value = ValueType(stringValue) ?? initValue
        } else {
            value = initValue
        }
    }

    static func load(key: String) -> String? {
        let value = UserDefaults.standard.string(forKey: key)
        log.debug("DEBUG: Preference.load(\(key)): \(value ?? "(nil)"))")
        return value
    }

    static func save(key: String, value: String) {
        log.debug("DEBUG: Preference.save(\(key), \(value))")
        UserDefaults.standard.set(value, forKey: key)
    }
}

extension Preference where ValueType: EnumCollateNoCase {
    init(key: String? = nil) {
        self.init(key: key, wrappedValue: ValueType.defaultValue)
    }
}

struct Preferences {
    @Preference var reuseLastAccount  : BoolEnum          = .boolFalse
    @Preference var reuseLastCategory : BoolEnum          = .boolFalse
    @Preference var reuseLastPayee    : BoolEnum          = .boolFalse
    @Preference var defaultStatus     : TransactionStatus = .none
}

extension Preferences {
    init(prefix: String?) {
        self.$reuseLastAccount  = prefix?.appending("reuseLastAccount")
        self.$reuseLastCategory = prefix?.appending("reuseLastCategory")
        self.$reuseLastPayee    = prefix?.appending("reuseLastPayee")
        self.$defaultStatus     = prefix?.appending("defaultStatus")
    }
}

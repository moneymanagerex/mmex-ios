//
//  EnterPreference.swift
//  MMEX
//
//  2024-11-15: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

struct EnterPreference {
    @StoredPreference var reuseLastAccount  : BoolChoice          = .boolFalse
    @StoredPreference var reuseLastCategory : BoolChoice          = .boolFalse
    @StoredPreference var reuseLastPayee    : BoolChoice          = .boolFalse
    @StoredPreference var defaultStatus     : TransactionStatus = .none
}

extension EnterPreference {
    init(prefix: String?) {
        self.$reuseLastAccount  = prefix?.appending("reuseLastAccount")
        self.$reuseLastCategory = prefix?.appending("reuseLastCategory")
        self.$reuseLastPayee    = prefix?.appending("reuseLastPayee")
        self.$defaultStatus     = prefix?.appending("defaultStatus")
    }
}

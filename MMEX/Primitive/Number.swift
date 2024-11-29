//
//  Number.swift
//  MMEX
//
//  2024-09-22: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

// Int with default(set)
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

// Double with default(set)
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

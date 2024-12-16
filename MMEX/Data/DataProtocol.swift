//
//  Data.swift
//  MMEX
//
//  2024-09-22: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

protocol DataProtocol: ExportableEntity {
    static var dataName: (String, String) { get }

    var id: DataId { get set }
    func shortDesc() -> String

    mutating func copy()
    @MainActor mutating func update(_ vm: ViewModel) -> String?
    @MainActor func delete(_ vm: ViewModel) -> String?

    mutating func resolveConstraint(conflictingWith existing: Self?) -> Bool
}

extension DataProtocol {
    static func copy(of s: String) -> String {
        return s + " (Copy)"
    }
}

//
//  GroupChoiceProtocol.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

protocol GroupChoiceProtocol: EnumCollateNoCase, Hashable
where Self.AllCases: RandomAccessCollection {
    static var isSingleton: Set<Self> { get }
    var fullName: String { get }
}

extension GroupChoiceProtocol {
    var fullName: String { self.rawValue }
}

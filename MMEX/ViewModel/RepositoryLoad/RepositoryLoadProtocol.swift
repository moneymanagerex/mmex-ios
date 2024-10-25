//
//  RepositoryLoadProtocol.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

protocol RepositoryLoadProtocol: Copyable {
    associatedtype ValueType: Copyable

    var state: RepositoryLoadState { get set }
    var value: ValueType { get set }

    func fetch(env: EnvironmentManager) -> ValueType?
    mutating func unload()
}

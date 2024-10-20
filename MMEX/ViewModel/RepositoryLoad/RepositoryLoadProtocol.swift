//
//  RepositoryLoadProtocol.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum RepositoryLoadState<DataType: Copyable>: Copyable {
    case error(String)
    case idle
    case loading
    case ready(DataType)
    
    init() {
        self = .idle
    }
}

protocol RepositoryLoadProtocol {
    associatedtype DataType: Copyable
    var state: RepositoryLoadState<DataType> { get set }
    func load(env: EnvironmentManager) -> DataType?
    mutating func unload()
}

extension RepositoryLoadProtocol {
    mutating func unload() {
        self.state = .idle
    }
}

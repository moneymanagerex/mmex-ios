//
//  RepositoryLoadProtocol.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum RepositoryLoadState<LoadType: Copyable>: Copyable {
    case error(String)
    case idle
    case loading
    case ready(LoadType)
    
    init() {
        self = .idle
    }
}

extension RepositoryLoadState: Equatable where LoadType: Equatable { }

protocol RepositoryLoadProtocol {
    associatedtype LoadType: Copyable
    var state: RepositoryLoadState<LoadType> { get set }
    func load(env: EnvironmentManager) -> LoadType?
    mutating func unload()
}

extension RepositoryLoadProtocol {
    mutating func unload() {
        self.state = .idle
    }
}

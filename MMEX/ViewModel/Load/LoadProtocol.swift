//
//  LoadProtocol.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

protocol LoadProtocol: Copyable {
    associatedtype ValueType: Copyable

    var loadName: String { get }
    var idleValue: ValueType { get }

    var state: LoadState { get set }
    var value: ValueType { get set }

    mutating func unload()
}

extension LoadProtocol {
    var readyValue: ValueType? { state == .ready ? value : nil }

    mutating func unload() {
        guard state.unloading() else { return }
        let loadName = self.loadName
        log.trace("DEBUG: LoadProtocol.unload(\(loadName), main=\(Thread.isMainThread))")
        value = idleValue
        state.unloaded()
    }
}

protocol LoadFetchProtocol: LoadProtocol {
    nonisolated func fetchValue(env: EnvironmentManager) async -> ValueType?
}

protocol LoadEvalProtocol: LoadProtocol {
    nonisolated func evalValue(env: EnvironmentManager, vm: ViewModel) async -> ValueType?
}
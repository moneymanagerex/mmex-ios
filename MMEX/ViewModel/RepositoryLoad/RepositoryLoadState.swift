//
//  RepositoryLoadProtocol.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

enum RepositoryLoadState: Int, Copyable, Equatable {
    case idle
    case loading
    case ready
    case error

    init() {
        self = .idle
    }
}

extension RepositoryLoadState {
    mutating func loading() -> Bool {
        guard self.rawValue < Self.loading.rawValue else { return false }
        self = .loading
        return true
    }

    mutating func loaded(ok: Bool = true) {
        guard self == .loading else { return }
        self = ok ? .ready : .error
    }

    mutating func unloading() -> Bool {
        guard self.rawValue > Self.loading.rawValue else { return false }
        self = .loading
        return true
    }

    mutating func unloaded() {
        guard self == .loading else { return }
        self = .idle
    }
}

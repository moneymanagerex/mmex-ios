//
//  LoadState.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

// store associated values outside of this enum, in order to simplify their update
enum LoadState: Int, Copyable, Equatable {
    case idle
    case loading
    case ready
    case error

    init() {
        self = .idle
    }
}

extension LoadState {
    mutating func loading() -> Bool {
        guard self.rawValue < Self.loading.rawValue else { return false }
        self = .loading
        return true
    }

    mutating func unloading() -> Bool {
        guard self.rawValue > Self.loading.rawValue else { return false }
        self = .loading
        return true
    }

    mutating func reloading() -> Bool {
        guard self.rawValue != Self.loading.rawValue else { return false }
        self = .loading
        return true
    }

    mutating func loaded(ok: Bool = true) {
        guard self == .loading else { return }
        self = ok ? .ready : .error
    }

    mutating func unloaded() {
        guard self == .loading else { return }
        self = .idle
    }

    mutating func unload() {
        guard self.rawValue > Self.loading.rawValue else { return }
        self = .idle
    }
}

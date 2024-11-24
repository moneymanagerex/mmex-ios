//
//  LoadRepository.swift
//  MMEX
//
//  2024-10-19: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite
import Combine

extension ViewModel {
    func load<RepositoryLoadType: LoadFetchProtocol>(
        _ pref: Preference,
        keyPath: ReferenceWritableKeyPath<ViewModel, RepositoryLoadType>
    ) async -> Bool {
        guard self[keyPath: keyPath].state.loading() else {
            return self[keyPath: keyPath].state == .ready
        }
        let loadName = self[keyPath: keyPath].loadName
        //log.trace("DEBUG: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        let value = await self[keyPath: keyPath].fetchValue(pref: pref, vm: self)
        if let value {
            self[keyPath: keyPath].value = value
        }
        let ok = value != nil
        self[keyPath: keyPath].state.loaded(ok: ok)
        if ok {
            log.info("INFO: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        } else {
            log.debug("ERROR: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        }
        return ok
    }

    func load<RepositoryLoadType: LoadEvalProtocol>(
        _ pref: Preference,
        keyPath: ReferenceWritableKeyPath<ViewModel, RepositoryLoadType>
    ) async -> Bool {
        guard self[keyPath: keyPath].state.loading() else {
            return self[keyPath: keyPath].state == .ready
        }
        let loadName = self[keyPath: keyPath].loadName
        //log.trace("DEBUG: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        let value = await self[keyPath: keyPath].evalValue(pref: pref, vm: self)
        if let value {
            self[keyPath: keyPath].value = value
        }
        let ok = value != nil
        self[keyPath: keyPath].state.loaded(ok: ok)
        if ok {
            log.info("INFO: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        } else {
            log.debug("ERROR: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        }
        return ok
    }

    func load<RepositoryLoadType: LoadFetchProtocol>(
        _ pref: Preference,
        _ taskGroup: inout TaskGroup<Bool>,
        keyPath: ReferenceWritableKeyPath<ViewModel, RepositoryLoadType>
    ) -> Bool {
        guard self[keyPath: keyPath].state.loading() else {
            return self[keyPath: keyPath].state == .ready
        }
        let loadName = self[keyPath: keyPath].loadName
        //log.trace("DEBUG: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        taskGroup.addTask(priority: .background) {
            let value = await self[keyPath: keyPath].fetchValue(pref: pref, vm: self)
            let ok = value != nil
            await MainActor.run {
                if let value {
                    self[keyPath: keyPath].value = value
                }
                self[keyPath: keyPath].state.loaded(ok: ok)
            }
            if ok {
                log.info("INFO: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
            } else {
                log.debug("ERROR: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
            }
            return ok
        }
        return true
    }

    func load<RepositoryLoadType: LoadEvalProtocol>(
        _ pref: Preference,
        _ taskGroup: inout TaskGroup<Bool>,
        keyPath: ReferenceWritableKeyPath<ViewModel, RepositoryLoadType>
    ) -> Bool {
        guard self[keyPath: keyPath].state.loading() else {
            return self[keyPath: keyPath].state == .ready
        }
        let loadName = self[keyPath: keyPath].loadName
        //log.trace("DEBUG: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
        taskGroup.addTask(priority: .background) {
            let value = await self[keyPath: keyPath].evalValue(pref: pref, vm: self)
            let ok = value != nil
            await MainActor.run {
                if let value {
                    self[keyPath: keyPath].value = value
                }
                self[keyPath: keyPath].state.loaded(ok: ok)
            }
            if ok {
                log.info("INFO: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
            } else {
                log.debug("ERROR: ViewModel.load(\(loadName), main=\(Thread.isMainThread))")
            }
            return ok
        }
        return true
    }

    func taskGroupOk(_ taskGroup: TaskGroup<Bool>, _ ok: Bool = true) async -> Bool {
        var ok = ok
        for await taskOk in taskGroup {
            if !taskOk { ok = false }
        }
        return ok
    }
}

//
//  JournalList.swift
//  MMEX
//
//  2024-11-08: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension ViewModel {
    func loadJournalList() async {
        guard journalList.reloading() else { return }
        log.trace("DEBUG: ViewModel.loadJournalList(main=\(Thread.isMainThread))")
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        journalList.loaded(ok: ok)
        if ok {
            log.info("INFO: ViewModel.loadJournalList(main=\(Thread.isMainThread))")
        } else {
            log.debug("ERROR: ViewModel.loadJournalList(main=\(Thread.isMainThread))")
            return
        }
    }

    func unloadJournalList() {
        guard journalList.unloading() else { return }
        log.trace("DEBUG: ViewModel.unloadJournalList(main=\(Thread.isMainThread))")
        journalList.unloaded()
    }
}

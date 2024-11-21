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
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        journalList.loaded(ok: ok)
    }
}

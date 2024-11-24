//
//  ReportList.swift
//  MMEX
//
//  2024-11-21: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct ReportList: ListProtocol {
    typealias MainRepository = ReportRepository

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var used  : LoadMainUsed<MainRepository>  = .init()  // always empty
    var order : LoadMainOrder<MainRepository> = .init(order: [MainRepository.col_name])
}

extension ReportList {
    mutating func unloadAll() {
        guard reloading() else { return }
        count.unload()
        data.unload()
        used.unload()
        order.unload()
        unloaded()
    }
}

extension ViewModel {
    func loadReportList(_ pref: Preference) async {
        guard reportList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.reportList.data),
                load(pref, &taskGroup, keyPath: \Self.reportList.used),
                load(pref, &taskGroup, keyPath: \Self.reportList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        reportList.loaded(ok: ok)
    }
}

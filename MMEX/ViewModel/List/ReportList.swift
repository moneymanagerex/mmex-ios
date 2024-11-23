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

extension ViewModel {
    func loadReportList(_ pref: Preference) async {
        guard reportList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.reportList.data),
                load(&taskGroup, keyPath: \Self.reportList.used),
                load(&taskGroup, keyPath: \Self.reportList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        reportList.loaded(ok: ok)
    }

    func unloadReportList() {
        guard reportList.reloading() else { return }
        reportList.count.unload()
        reportList.data.unload()
        reportList.used.unload()
        reportList.order.unload()
        reportList.unloaded()
    }
}

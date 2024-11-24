//
//  AttachmentList.swift
//  MMEX
//
//  2024-11-05: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct AttachmentList: ListProtocol {
    typealias MainRepository = AttachmentRepository

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var used  : LoadMainUsed<MainRepository>  = .init()  // always empty
    var order : LoadMainOrder<MainRepository> = .init(order: [
        MainRepository.col_filename,
        MainRepository.col_refType,
        MainRepository.col_refId
    ])
}

extension AttachmentList {
    mutating func unload() {
        guard reloading() else { return }
        count.unload()
        data.unload()
        used.unload()
        order.unload()
        unloaded()
    }
}

extension ViewModel {
    func loadAttachmentList(_ pref: Preference) async {
        guard attachmentList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.attachmentList.data),
                load(pref, &taskGroup, keyPath: \Self.attachmentList.used),
                load(pref, &taskGroup, keyPath: \Self.attachmentList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        attachmentList.loaded(ok: ok)
    }
}

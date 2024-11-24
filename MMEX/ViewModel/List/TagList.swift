//
//  TagList.swift
//  MMEX
//
//  2024-11-05: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct TagList: ListProtocol {
    typealias MainRepository = TagRepository

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var used  : LoadMainUsed<MainRepository>  = .init()
    var order : LoadMainOrder<MainRepository> = .init(order: [MainRepository.col_name])
}

extension TagList {
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
    func loadTagList(_ pref: Preference) async {
        guard tagList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.tagList.data),
                load(pref, &taskGroup, keyPath: \Self.tagList.used),
                load(pref, &taskGroup, keyPath: \Self.tagList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        tagList.loaded(ok: ok)
    }
}

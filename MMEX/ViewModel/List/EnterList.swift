//
//  EnterList.swift
//  MMEX
//
//  2024-11-08: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension ViewModel {
    func loadEnterList(_ pref: Preference) async {
        guard enterList.reloading() else { return }
        var ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.infotableList.defaultAccountId),
                //load(pref, &taskGroup, keyPath: \Self.infotableList.categoryDelimiter),
                load(pref, &taskGroup, keyPath: \Self.currencyList.info),
                load(pref, &taskGroup, keyPath: \Self.accountList.data),
                load(pref, &taskGroup, keyPath: \Self.accountList.order),
                load(pref, &taskGroup, keyPath: \Self.categoryList.data),
                load(pref, &taskGroup, keyPath: \Self.categoryList.order),
                load(pref, &taskGroup, keyPath: \Self.payeeList.data),
                load(pref, &taskGroup, keyPath: \Self.payeeList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        if ok { ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.categoryList.evalPath),
                load(pref, &taskGroup, keyPath: \Self.categoryList.evalTree),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        } }
        enterList.loaded(ok: ok)
    }
}

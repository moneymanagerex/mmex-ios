//
//  SettingsList.swift
//  MMEX
//
//  2024-11-08: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension ViewModel {
    func loadSettingsList(_ pref: Preference) async {
        guard settingsList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.infotableList.baseCurrencyId),
                load(pref, &taskGroup, keyPath: \Self.infotableList.defaultAccountId),
                //load(pref, &taskGroup, keyPath: \Self.infotableList.categoryDelimiter),
                load(pref, &taskGroup, keyPath: \Self.currencyList.name),
                load(pref, &taskGroup, keyPath: \Self.currencyList.used),
                load(pref, &taskGroup, keyPath: \Self.currencyList.order),
                load(pref, &taskGroup, keyPath: \Self.accountList.data),
                load(pref, &taskGroup, keyPath: \Self.accountList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        settingsList.loaded(ok: ok)
    }
}

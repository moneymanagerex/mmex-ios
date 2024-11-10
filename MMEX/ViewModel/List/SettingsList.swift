//
//  SettingsList.swift
//  MMEX
//
//  2024-11-08: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension ViewModel {
    func loadSettingsList() async {
        guard settingsList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.infotableList.baseCurrencyId),
                load(&taskGroup, keyPath: \Self.infotableList.defaultAccountId),
                load(&taskGroup, keyPath: \Self.infotableList.categoryDelimiter),
                load(&taskGroup, keyPath: \Self.currencyList.name),
                load(&taskGroup, keyPath: \Self.currencyList.used),
                load(&taskGroup, keyPath: \Self.currencyList.order),
                load(&taskGroup, keyPath: \Self.accountList.data),
                load(&taskGroup, keyPath: \Self.accountList.order),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        settingsList.loaded(ok: ok)
    }

    func unloadSettingsList() {
        guard settingsList.unloading() else { return }
        settingsList.unloaded()
    }
}

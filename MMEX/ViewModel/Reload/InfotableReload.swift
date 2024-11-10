//
//  InfotableReload.swift
//  MMEX
//
//  2024-11-10: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadInfotable(baseCurrencyId newCurrencyId: DataId) async {
        log.trace("DEBUG: ViewModel.reloadInfotableList(main=\(Thread.isMainThread))")
        let oldCurrencyId = infotableList.baseCurrencyId.value
        if newCurrencyId == oldCurrencyId { return }

        var changed = false
        if !oldCurrencyId.isVoid {
            currencyList.used.unload()
            currencyList.info.unload()
            changed = true
        } else if !newCurrencyId.isVoid {
            if let currencyUsed = currencyList.used.readyValue, !currencyUsed.contains(newCurrencyId) {
                if currencyList.used.state.unloading() {
                    currencyList.used.value.insert(newCurrencyId)
                    currencyList.used.state.loaded()
                    changed = true
                }
            }
            if let currencyInfo = currencyList.info.readyValue, currencyInfo[newCurrencyId] == nil {
                currencyList.info.unload()
                changed = true
            }
        }

        if changed {
            unloadCurrencyGroup()
            currencyList.unload()
        }

        if infotableList.baseCurrencyId.state.unloading() {
            infotableList.baseCurrencyId.value = newCurrencyId
            infotableList.baseCurrencyId.state.loaded()
        }

        log.info("INFO: ViewModel.reloadInfotableList(baseCurrencyId:, main=\(Thread.isMainThread))")
    }
}

//
//  CurrencyReload.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadCurrencyList(_ oldData: CurrencyData?, _ newData: CurrencyData?) async {
        log.trace("DEBUG: ViewModel.reloadCurrencyList(main=\(Thread.isMainThread))")

        // vm.currencyList.info contains only used currencies
        if let _ = oldData, let newData {
            if currencyList.info.readyValue?[newData.id] != nil {
                if currencyList.info.state.unloading() {
                    currencyList.info.value[newData.id] = CurrencyInfo(newData)
                    currencyList.info.state.loaded()
                }
            }
        }

        // save isExpanded
        let groupIsExpanded: [Bool]? = currencyGroup.readyValue?.map { $0.isExpanded }

        unloadCurrencyGroup()
        currencyList.unload()

        if (oldData != nil) != (newData != nil) {
            currencyList.count.unload()
        }

        if currencyList.data.state.unloading() {
            if let newData {
                currencyList.data.value[newData.id] = newData
            } else if let oldData {
                currencyList.data.value[oldData.id] = nil
            }
            currencyList.data.state.loaded()
        }

        if currencyList.name.state.unloading() {
            if let newData {
                currencyList.name.value[newData.id] = newData.name
            } else if let oldData {
                currencyList.name.value[oldData.id] = nil
            }
            currencyList.name.state.loaded()
        }

        currencyList.order.unload()

        await reloadCurrencyList()
        loadCurrencyGroup(choice: currencyGroup.choice)

        // restore isExpanded
        if let groupIsExpanded, currencyGroup.value.count == groupIsExpanded.count {
            for g in 0 ..< groupIsExpanded.count {
                currencyGroup.value[g].isExpanded = groupIsExpanded[g]
            }
        }

        log.info("INFO: ViewModel.reloadCurrencyList(main=\(Thread.isMainThread))")
    }
}

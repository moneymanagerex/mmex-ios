//
//  AccountReload.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadAccountList(_ oldData: AccountData?, _ newData: AccountData?) async {
        log.trace("DEBUG: ViewModel.reloadAccountList(main=\(Thread.isMainThread))")

        if
            let newCurrencyId = newData?.currencyId,
            let currencyInfo = currencyList.info.readyValue,
            currencyInfo[newCurrencyId] == nil
        {
            if
                let currencyData = currencyList.data.readyValue,
                let newCurrencyData = currencyData[newCurrencyId]
            {
                if currencyList.info.state.unloading() {
                    currencyList.info.value[newCurrencyId] = CurrencyInfo(newCurrencyData)
                    currencyList.info.state.loaded()
                }
            } else {
                currencyList.info.unload()
            }
        }

        var currencyChanged = false
        if let currencyUsed = currencyList.used.readyValue {
            let oldCurrencyId = oldData?.currencyId
            let newCurrencyId = newData?.currencyId
            if let oldCurrencyId, newCurrencyId != oldCurrencyId {
                currencyList.used.unload()
                currencyChanged = true
            } else if let newCurrencyId, !currencyUsed.contains(newCurrencyId) {
                if currencyList.used.state.unloading() {
                    currencyList.used.value.insert(newCurrencyId)
                    currencyList.used.state.loaded()
                    currencyChanged = true
                }
            }
        }
        if currencyChanged {
            unloadCurrencyGroup()
            currencyList.unload()
        }

        // save isExpanded
        let groupIsExpanded: [Bool]? = accountGroup.readyValue?.map { $0.isExpanded }
        let currencyIndex: [DataId: Int] = Dictionary(
            uniqueKeysWithValues: accountGroup.groupCurrency.enumerated().map { ($0.1, $0.0) }
        )

        unloadAccountGroup()
        accountList.unload()

        if (oldData != nil) != (newData != nil) {
            accountList.count.unload()
        }

        if accountList.data.state.unloading() {
            if let newData {
                accountList.data.value[newData.id] = newData
            } else if let oldData {
                accountList.data.value[oldData.id] = nil
            }
            accountList.data.state.loaded()
        }

        accountList.order.unload()

        if let _ = newData {
            accountList.att.unload()
        } else if let oldData {
            if accountList.att.state.unloading() {
                accountList.att.value[oldData.id] = nil
                accountList.att.state.loaded()
            }
        }

        await loadAccountList()
        loadAccountGroup(choice: accountGroup.choice)

        // restore isExpanded
        if let groupIsExpanded { switch accountGroup.choice {
        case .currency:
            for (g, currencyId) in accountGroup.groupCurrency.enumerated() {
                guard let i = currencyIndex[currencyId] else { continue }
                accountGroup.value[g].isExpanded = groupIsExpanded[i]
            }
        default:
            if accountGroup.value.count == groupIsExpanded.count {
                for g in 0 ..< groupIsExpanded.count {
                    accountGroup.value[g].isExpanded = groupIsExpanded[g]
                }
            }
        } }

        log.info("INFO: ViewModel.reloadAccountList(main=\(Thread.isMainThread))")
    }
}

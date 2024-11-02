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

        if let newData {
            if env.currencyCache[newData.currencyId] == nil {
                env.loadCurrency()
            }
            env.accountCache.update(id: newData.id, data: newData)
        } else if let oldData {
            env.accountCache[oldData.id] = nil
        }

        if let currencyUsed = currencyList.used.readyValue {
            let oldCurrency = oldData?.currencyId
            let newCurrency = newData?.currencyId
            if let oldCurrency, newCurrency != oldCurrency {
                currencyList.used.unload()
            } else if let newCurrency, !currencyUsed.contains(newCurrency) {
                if currencyList.used.state.unloading() {
                    currencyList.used.value.insert(newCurrency)
                    currencyList.used.state.loaded()
                }
            }
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

        if accountList.name.state.unloading() {
            if let newData {
                accountList.name.value[newData.id] = newData.name
            } else if let oldData {
                accountList.name.value[oldData.id] = nil
            }
            accountList.name.state.loaded()
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

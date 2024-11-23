//
//  AccountReload.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadAccount(_ pref: Preference, _ oldData: AccountData?, _ newData: AccountData?) async {
        log.trace("DEBUG: ViewModel.reloadAccount(main=\(Thread.isMainThread))")
        
        reloadCurrencyUsed(pref, oldData?.currencyId, newData?.currencyId)
        
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
        
        await loadAccountList(pref)
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
        
        log.info("INFO: ViewModel.reloadAccount(main=\(Thread.isMainThread))")
    }

    func reloadAccountUsed(_ pref: Preference, _ oldId: DataId?, _ newId: DataId?) {
        log.trace("DEBUG: ViewModel.reloadAccountUsed(main=\(Thread.isMainThread), \(oldId?.value ?? 0), \(newId?.value ?? 0))")
        if let oldId, newId != oldId {
            if accountGroup.choice == .used {
                unloadAccountGroup()
            }
            accountList.used.unload()
        } else if
            let accountUsed = accountList.used.readyValue,
            let newId, !accountUsed.contains(newId)
        {
            if accountGroup.choice == .used {
                unloadAccountGroup()
            }
            if accountList.used.state.unloading() {
                accountList.used.value.insert(newId)
                accountList.used.state.loaded()
            }
        }
    }

    func reloadAccountAtt(_ pref: Preference) {
        log.trace("DEBUG: ViewModel.reloadAccountAtt(main=\(Thread.isMainThread))")
        if accountGroup.choice == .attachment {
            unloadAccountGroup()
        }
        accountList.att.unload()
    }
}

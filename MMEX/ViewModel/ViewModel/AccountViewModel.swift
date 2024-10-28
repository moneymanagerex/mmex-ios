//
//  AccountViewModel.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func loadAccountList() async {
        guard accountList.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadAccountList(main=\(Thread.isMainThread))")
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.accountList.data),
                load(&taskGroup, keyPath: \Self.accountList.used),
                load(&taskGroup, keyPath: \Self.accountList.order),
                load(&taskGroup, keyPath: \Self.accountList.att),
                // used in EditView
                load(&taskGroup, keyPath: \Self.currencyList.name),
                load(&taskGroup, keyPath: \Self.currencyList.order),
            ].allSatisfy({$0})
            return await taskGroupOk(taskGroup, ok)
        }
        accountList.state.loaded(ok: ok)
        if ok {
            log.info("INFO: ViewModel.loadAccountList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: ViewModel.loadAccountList(main=\(Thread.isMainThread)): Error.")
            return
        }
    }

    func unloadAccountList() {
        guard accountList.state.unloading() else { return }
        log.trace("DEBUG: ViewModel.unloadAccountList(main=\(Thread.isMainThread))")
        accountList.data.unload()
        accountList.used.unload()
        accountList.order.unload()
        accountList.att.unload()
        accountList.state.unloaded()
    }
}

extension ViewModel {
    func loadAccountGroup(choice: AccountGroupChoice) {
        guard
            let listData     = accountList.data.readyValue,
            let listUsed     = accountList.used.readyValue,
            let listOrder    = accountList.order.readyValue,
            let listAtt      = accountList.att.readyValue,
            let currencyName = currencyList.name.readyValue
        else { return }

        guard accountGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadAccountGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        accountGroup.choice = choice
        accountGroup.groupCurrency = []

        switch choice {
        case .all:
            accountGroup.append("All", listOrder, true, true)
        case .used:
            let dict = Dictionary(grouping: listOrder) { listUsed.contains($0) }
            for g in AccountGroup.groupUsed {
                let name = g ? "Used" : "Other"
                accountGroup.append(name, dict[g] ?? [], true, g)
            }
        case .favorite:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.favoriteAcct }
            for g in AccountGroup.groupFavorite {
                let name = g == .boolTrue ? "Favorite" : "Other"
                accountGroup.append(name, dict[g] ?? [], true, g == .boolTrue)
            }
        case .status:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.status }
            for g in AccountGroup.groupStatus {
                accountGroup.append(g.rawValue, dict[g] ?? [], true, true)
            }
        case .type:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.type }
            for g in AccountGroup.groupType {
                accountGroup.append(g.rawValue, dict[g] ?? [], dict[g] != nil, true)
            }
        case .currency:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.currencyId }
            accountGroup.groupCurrency = currencyName.compactMap {
                dict[$0.key] != nil ? ($0.key, $0.value) : nil
            }.sorted { $0.1 < $1.1 }.map { $0.0 }
            for g in accountGroup.groupCurrency {
                let name = currencyName[g]
                accountGroup.append(name, dict[g] ?? [], dict[g] != nil, true)
            }
        case .attachment:
            let dict = Dictionary(grouping: listOrder) { listAtt[$0]?.count ?? 0 > 0 }
            for g in AccountGroup.groupAttachment {
                let name = g ? "With Attachment" : "Other"
                accountGroup.append(name, dict[g] ?? [], true, g)
            }
        }
        
        accountGroup.state.loaded()
    }

    func unloadAccountGroup() {
        accountGroup.unload()
    }
}

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
        accountList.state.unload()

        if (oldData != nil) != (newData != nil) {
            manageList.unload()
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

        if accountList.att.state.unloading() {
            if let _ = newData {
                accountList.att.state.unloaded()
            } else if let oldData {
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
    }
}

extension ViewModel {
    func accountGroupIsVisible(_ g: Int, search: AccountSearch
    ) -> Bool? {
        guard
            let listData  = accountList.data.readyValue,
            let groupData = accountGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch accountGroup.choice {
            case .type, .currency: !groupData[g].dataId.isEmpty
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(self, listData[$0]!) }) != nil
    }

    func searchAccountGroup(search: AccountSearch, expand: Bool = false ) {
        //log.trace("DEBUG: ViewModel.searchAccountGroup()")
        guard accountGroup.state == .ready else { return }
        for g in 0 ..< accountGroup.value.count {
            guard let isVisible = accountGroupIsVisible(g, search: search) else { return }
            //log.debug("DEBUG: ViewModel.searchAccountGroup(): \(g) = \(isVisible)")
            accountGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                accountGroup.value[g].isExpanded = true
            }
        }
    }
}

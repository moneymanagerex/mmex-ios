//
//  PayeeViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

enum PayeeGroupChoice: String, RepositoryGroupChoiceProtocol {
    case all      = "All"
    case used     = "Used"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct PayeeGroup: RepositoryGroupProtocol {
    typealias MainRepository = PayeeRepository
    typealias GroupChoice    = PayeeGroupChoice

    var choice: GroupChoice = .defaultValue
    var state: RepositoryLoadState = .init()
    var value: ValueType = []
}

struct PayeeSearch: RepositorySearchProtocol {
    var area: [RepositorySearchArea<PayeeData>] = [
        ("Name",  true,  [ {$0.name} ]),
    ]
    var key: String = ""
}

extension RepositoryViewModel {
    func loadPayeeList() async {
        guard payeeList.state.loading() else { return }
        log.trace("DEBUG: RepositoryViewModel.loadPayeeList(main=\(Thread.isMainThread))")
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.payeeData)
            load(queue: &queue, keyPath: \Self.payeeOrder)
            load(queue: &queue, keyPath: \Self.payeeUsed)
            return await allOk(queue: queue)
        }
        payeeList.state.loaded(ok: queueOk)
        if queueOk {
            log.info("INFO: RepositoryViewModel.loadPayeeList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: RepositoryViewModel.loadPayeeList(main=\(Thread.isMainThread)): Cannot load.")
            return
        }
    }

    func unloadPayeeList() {
        guard payeeList.state.unloading() else { return }
        log.trace("DEBUG: RepositoryViewModel.unloadPayeeList(main=\(Thread.isMainThread))")
        payeeData.unload()
        payeeOrder.unload()
        payeeUsed.unload()
        payeeList.state.loaded()
    }
}

extension RepositoryViewModel {
    func loadPayeeGroup(choice: PayeeGroupChoice) {
    }

    func unloadPayeeGroup() {
        payeeGroup.unload()
    }
}

extension RepositoryViewModel {
    func reloadPayeeList(_ oldData: PayeeData?, _ newData: PayeeData?) async {
    }
}

extension RepositoryViewModel {
    func payeeGroupIsVisible(_ g: Int, search: PayeeSearch
    ) -> Bool? {
        guard
            payeeData.state  == .ready,
            payeeGroup.state == .ready
        else { return nil }

        let dataDict  = payeeData.value
        let groupData = payeeGroup.value

        if search.isEmpty {
            return switch payeeGroup.choice {
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(dataDict[$0]!) }) != nil
    }

    func searchPayeeGroup(search: PayeeSearch, expand: Bool = false ) {
        guard payeeGroup.state == .ready else { return }
        for g in 0 ..< payeeGroup.value.count {
            guard let isVisible = payeeGroupIsVisible(g, search: search) else { return }
            payeeGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                payeeGroup.value[g].isExpanded = true
            }
        }
    }
}

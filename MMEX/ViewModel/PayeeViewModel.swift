//
//  PayeeViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum PayeeGroupChoice: String, RepositoryGroupChoiceProtocol {
    case all      = "All"
    case used     = "Used"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct PayeeGroup: RepositoryLoadGroupProtocol {
    typealias GroupChoice    = PayeeGroupChoice
    typealias RepositoryType = PayeeRepository
    
    var choice: GroupChoice = .defaultValue
    var state: RepositoryLoadState<[[DataId]]> = .init()
    var isVisible  : [Bool] = []
    var isExpanded : [Bool] = []
}

extension RepositoryViewModel {
    func loadPayeeList() async {
        log.trace("DEBUG: RepositoryViewModel.loadPayeeList(main=\(Thread.isMainThread))")
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.payeeDataDict)
            load(queue: &queue, keyPath: \Self.payeeDataOrder)
            load(queue: &queue, keyPath: \Self.payeeDataUsed)
            return await allOk(queue: queue)
        }
        payeeList.state = queueOk ? .ready(()) : .error("Cannot load data.")
        if queueOk {
            log.info("INFO: RepositoryViewModel.loadPayeeList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: RepositoryViewModel.loadPayeeList(main=\(Thread.isMainThread)): Cannot load data.")
            return
        }
    }

    func unloadPayeeList() {
        log.trace("DEBUG: RepositoryViewModel.unloadPayeeList(main=\(Thread.isMainThread))")
        payeeDataDict.unload()
        payeeDataOrder.unload()
        payeeDataUsed.unload()
        payeeList.state = .idle
    }
}

extension RepositoryViewModel {
    func unloadPayeeGroup() -> Bool? {
        log.trace("DEBUG: RepositoryViewModel.unloadPayeeGroup(main=\(Thread.isMainThread))")
        if case .loading = payeeGroup.state { return nil }
        payeeGroup.state = .idle
        payeeGroup.isVisible  = []
        payeeGroup.isExpanded = []
        return true
    }
}

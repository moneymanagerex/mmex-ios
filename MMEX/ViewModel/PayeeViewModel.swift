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
    typealias MainRepository = PayeeRepository
    
    var choice: GroupChoice = .defaultValue
    var state: RepositoryLoadState<[RepositoryGroupData]> = .init()
    var isVisible  : [Bool] = []
    var isExpanded : [Bool] = []
}

extension RepositoryViewModel {
    func loadPayeeList() async {
        log.trace("DEBUG: RepositoryViewModel.loadPayeeList(main=\(Thread.isMainThread))")
        guard case .idle = payeeList.state else { return }
        payeeList.state = .loading
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.payeeData)
            load(queue: &queue, keyPath: \Self.payeeOrder)
            load(queue: &queue, keyPath: \Self.payeeUsed)
            return await allOk(queue: queue)
        }
        payeeList.state = queueOk ? .ready(()) : .error("Cannot load.")
        if queueOk {
            log.info("INFO: RepositoryViewModel.loadPayeeList(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: RepositoryViewModel.loadPayeeList(main=\(Thread.isMainThread)): Cannot load.")
            return
        }
    }

    func unloadPayeeList() {
        log.trace("DEBUG: RepositoryViewModel.unloadPayeeList(main=\(Thread.isMainThread))")
        if case .loading = payeeList.state { return }
        payeeList.state = .loading
        payeeData.unload()
        payeeOrder.unload()
        payeeUsed.unload()
        payeeList.state = .idle
    }
}

extension RepositoryViewModel {
    func unloadPayeeGroup() {
        log.trace("DEBUG: RepositoryViewModel.unloadPayeeGroup(main=\(Thread.isMainThread))")
        if case .loading = payeeGroup.state { return }
        payeeGroup.state = .loading
        payeeGroup.isVisible  = []
        payeeGroup.isExpanded = []
        payeeGroup.state = .idle
    }
}

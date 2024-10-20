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
    func loadPayeeData() async {
        log.trace("DEBUG: RepositoryViewModel.loadPayeeData(main=\(Thread.isMainThread))")
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.payeeDict)
            load(queue: &queue, keyPath: \Self.payeeOrder)
            load(queue: &queue, keyPath: \Self.payeeUsed)
            return await allOk(queue: queue)
        }
        payeeData.state = queueOk ? .ready(()) : .error("Cannot load data.")
        if queueOk {
            log.info("INFO: RepositoryViewModel.loadPayeeData(main=\(Thread.isMainThread)): Ready.")
        } else {
            log.debug("ERROR: RepositoryViewModel.loadPayeeData(main=\(Thread.isMainThread)): Cannot load data.")
            return
        }
    }

    func unloadPayeeData() {
        log.trace("DEBUG: RepositoryViewModel.unloadPayeeData(main=\(Thread.isMainThread))")
        payeeDict.unload()
        payeeOrder.unload()
        payeeUsed.unload()
        payeeData.state = .idle
    }
}

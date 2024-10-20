//
//  PayeeViewModel.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension RepositoryViewModel {
    func loadPayeeList() async {
        let queueOk = await withTaskGroup(of: Bool.self) { queue -> Bool in
            load(queue: &queue, keyPath: \Self.payeeDict)
            load(queue: &queue, keyPath: \Self.payeeOrder)
            load(queue: &queue, keyPath: \Self.payeeUsed)
            return await allOk(queue: queue)
        }
        payeeList.state = queueOk ? .ready(()) : .error("Cannot load data.")
    }

    func unloadPayeeList() {
        payeeDict.unload()
        payeeOrder.unload()
        payeeUsed.unload()
        payeeList.state = .idle
    }
}

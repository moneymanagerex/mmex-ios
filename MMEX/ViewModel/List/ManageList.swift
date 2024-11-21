//
//  ManageList.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension ViewModel {
    func loadManageList() async {
        guard manageList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.infotableList.count),
                load(&taskGroup, keyPath: \Self.currencyList.count),
                load(&taskGroup, keyPath: \Self.accountList.count),
                load(&taskGroup, keyPath: \Self.assetList.count),
                load(&taskGroup, keyPath: \Self.stockList.count),
                load(&taskGroup, keyPath: \Self.categoryList.count),
                load(&taskGroup, keyPath: \Self.payeeList.count),
                load(&taskGroup, keyPath: \Self.transactionList.count),
                load(&taskGroup, keyPath: \Self.scheduledList.count),
                load(&taskGroup, keyPath: \Self.tagList.count),
                load(&taskGroup, keyPath: \Self.fieldList.count),
                load(&taskGroup, keyPath: \Self.attachmentList.count),
                load(&taskGroup, keyPath: \Self.yearList.count),
                load(&taskGroup, keyPath: \Self.budgetList.count),
                load(&taskGroup, keyPath: \Self.reportList.count),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        manageList.loaded(ok: ok)
    }
}

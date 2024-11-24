//
//  ManageList.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension ViewModel {
    func loadManageList(_ pref: Preference) async {
        guard manageList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.infotableList.count),
                load(pref, &taskGroup, keyPath: \Self.currencyList.count),
                load(pref, &taskGroup, keyPath: \Self.accountList.count),
                load(pref, &taskGroup, keyPath: \Self.assetList.count),
                load(pref, &taskGroup, keyPath: \Self.stockList.count),
                load(pref, &taskGroup, keyPath: \Self.categoryList.count),
                load(pref, &taskGroup, keyPath: \Self.payeeList.count),
                load(pref, &taskGroup, keyPath: \Self.transactionList.count),
                load(pref, &taskGroup, keyPath: \Self.scheduledList.count),
                load(pref, &taskGroup, keyPath: \Self.tagList.count),
                load(pref, &taskGroup, keyPath: \Self.fieldList.count),
                load(pref, &taskGroup, keyPath: \Self.attachmentList.count),
                load(pref, &taskGroup, keyPath: \Self.budgetPeriodList.count),
                load(pref, &taskGroup, keyPath: \Self.budgetList.count),
                load(pref, &taskGroup, keyPath: \Self.reportList.count),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        manageList.loaded(ok: ok)
    }
}

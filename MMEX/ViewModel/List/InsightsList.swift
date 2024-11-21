//
//  InsightsList.swift
//  MMEX
//
//  2024-11-08: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension ViewModel {
    func reloadInsightsList() async {
        guard insightsList.reloading() else { return }
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.currencyList.info),
                load(&taskGroup, keyPath: \Self.accountList.data),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        insightsList.loaded(ok: ok)
    }
}

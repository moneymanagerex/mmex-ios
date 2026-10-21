//
//  InsightsList.swift
//  MMEX
//
//  2024-11-08: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension ViewModel {
    func loadInsightsList(_ pref: Preference) async {
        guard insightsList.reloading() else { return }
        await loadAccountList(pref)
        await loadPayeeList(pref)
        await loadBudgetList(pref)
        await loadScheduledList(pref)
        
        let ok = [
            accountList.state,
            payeeList.state,
            budgetList.state,
            budgetPeriodList.state,
            scheduledList.state,
            categoryList.state,
            currencyList.state,
        ].allSatisfy { $0 == .ready }
        
        insightsList.loaded(ok: ok)
    }
}

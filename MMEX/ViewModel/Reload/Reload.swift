//
//  Reload.swift
//  MMEX
//
//  2024-10-19: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reload<MainData: DataProtocol>(_ pref: Preference, _ oldData: MainData?, _ newData: MainData?) async {
        /**/   if MainData.self == U.RepositoryData.self {
            await reloadCurrency(pref, oldData as! CurrencyData?, newData as! CurrencyData?)
        } else if MainData.self == A.RepositoryData.self {
            await reloadAccount(pref, oldData as! AccountData?, newData as! AccountData?)
        } else if MainData.self == E.RepositoryData.self {
            await reloadAsset(pref, oldData as! AssetData?, newData as! AssetData?)
        } else if MainData.self == S.RepositoryData.self {
            await reloadStock(pref, oldData as! StockData?, newData as! StockData?)
        } else if MainData.self == C.RepositoryData.self {
            await reloadCategory(pref, oldData as! CategoryData?, newData as! CategoryData?)
        } else if MainData.self == P.RepositoryData.self {
            await reloadPayee(pref, oldData as! PayeeData?, newData as! PayeeData?)
        } else if MainData.self == G.RepositoryData.self {
            await reloadTag(pref, oldData as! TagData?, newData as! TagData?)
        } else if MainData.self == F.RepositoryData.self {
            await reloadField(pref, oldData as! FieldData?, newData as! FieldData?)
        } else if MainData.self == D.RepositoryData.self {
            await reloadAttachment(pref, oldData as! AttachmentData?, newData as! AttachmentData?)
        } else if MainData.self == BP.RepositoryData.self {
            await reloadBudgetPeriod(pref, oldData as! BudgetPeriodData?, newData as! BudgetPeriodData?)
        } else if MainData.self == B.RepositoryData.self {
            await reloadBudget(pref, oldData as! BudgetData?, newData as! BudgetData?)
        } else if MainData.self == R.RepositoryData.self {
            await reloadReport(pref, oldData as! ReportData?, newData as! ReportData?)
        }
    }
}

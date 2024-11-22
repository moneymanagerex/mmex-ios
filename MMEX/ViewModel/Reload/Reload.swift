//
//  Reload.swift
//  MMEX
//
//  2024-10-19: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reload<MainData: DataProtocol>(_ oldData: MainData?, _ newData: MainData?) async {
        /**/   if MainData.self == U.RepositoryData.self {
            await reloadCurrency(oldData as! CurrencyData?, newData as! CurrencyData?)
        } else if MainData.self == A.RepositoryData.self {
            await reloadAccount(oldData as! AccountData?, newData as! AccountData?)
        } else if MainData.self == E.RepositoryData.self {
            await reloadAsset(oldData as! AssetData?, newData as! AssetData?)
        } else if MainData.self == S.RepositoryData.self {
            await reloadStock(oldData as! StockData?, newData as! StockData?)
        } else if MainData.self == C.RepositoryData.self {
            await reloadCategory(oldData as! CategoryData?, newData as! CategoryData?)
        } else if MainData.self == P.RepositoryData.self {
            await reloadPayee(oldData as! PayeeData?, newData as! PayeeData?)
        } else if MainData.self == G.RepositoryData.self {
            await reloadTag(oldData as! TagData?, newData as! TagData?)
        } else if MainData.self == D.RepositoryData.self {
            await reloadAttachment(oldData as! AttachmentData?, newData as! AttachmentData?)
        } else if MainData.self == BP.RepositoryData.self {
            await reloadBudgetPeriod(oldData as! BudgetPeriodData?, newData as! BudgetPeriodData?)
        } else if MainData.self == B.RepositoryData.self {
            await reloadBudget(oldData as! BudgetData?, newData as! BudgetData?)
        }
    }
}

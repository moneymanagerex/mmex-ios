//
//  Reload.swift
//  MMEX
//
//  2024-10-19: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadList<MainData: DataProtocol>(_ oldData: MainData?, _ newData: MainData?) async {
        if MainData.self == U.RepositoryData.self {
            await reloadCurrencyList(oldData as! CurrencyData?, newData as! CurrencyData?)
        } else if MainData.self == A.RepositoryData.self {
            await reloadAccountList(oldData as! AccountData?, newData as! AccountData?)
        } else if MainData.self == E.RepositoryData.self {
            await reloadAssetList(oldData as! AssetData?, newData as! AssetData?)
        } else if MainData.self == S.RepositoryData.self {
            await reloadStockList(oldData as! StockData?, newData as! StockData?)
        } else if MainData.self == C.RepositoryData.self {
            await reloadCategoryList(oldData as! CategoryData?, newData as! CategoryData?)
        } else if MainData.self == P.RepositoryData.self {
            await reloadPayeeList(oldData as! PayeeData?, newData as! PayeeData?)
        } else if MainData.self == G.RepositoryData.self {
            await reloadTagList(oldData as! TagData?, newData as! TagData?)
        }
    }
}

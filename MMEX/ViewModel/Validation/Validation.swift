//
//  Validation.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func isUsed<DataType: DataProtocol>(_ data: DataType) -> Bool? {
        if DataType.self == U.RepositoryData.self {
            return currencyList.used.readyValue?.contains(data.id)
        } else if DataType.self == A.RepositoryData.self {
            return accountList.used.readyValue?.contains(data.id)
        } else if DataType.self == E.RepositoryData.self {
            return assetList.used.readyValue?.contains(data.id)
        } else if DataType.self == S.RepositoryData.self {
            return stockList.used.readyValue?.contains(data.id)
        } else if DataType.self == C.RepositoryData.self {
            return categoryList.used.readyValue?.contains(data.id)
        } else if DataType.self == P.RepositoryData.self {
            return payeeList.used.readyValue?.contains(data.id)
        }
        return nil
    }

    func update<DataType: DataProtocol>(_ data: inout DataType) -> String? {
        if var data = data as? CurrencyData {
            return updateCurrency(&data)
        } else if var data = data as? AccountData {
            return updateAccount(&data)
        } else if var data = data as? AssetData {
            return updateAsset(&data)
        } else if var data = data as? StockData {
            return updateStock(&data)
        } else if var data = data as? CategoryData {
            return updateCategory(&data)
        } else if var data = data as? PayeeData {
            return updatePayee(&data)
        }
        return "* unknown data type"
    }

    func delete<DataType: DataProtocol>(_ data: DataType) -> String? {
        if let data = data as? CurrencyData {
            return deleteCurrency(data)
        } else if let data = data as? AccountData {
            return deleteAccount(data)
        } else if let data = data as? AssetData {
            return deleteAsset(data)
        } else if let data = data as? StockData {
            return deleteStock(data)
        } else if let data = data as? CategoryData {
            return deleteCategory(data)
        } else if let data = data as? PayeeData {
            return deletePayee(data)
        }
        return "* unknown data type"
    }
}

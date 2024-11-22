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
        /**/   if DataType.self == U.RepositoryData.self {
            return currencyList.used.readyValue?.contains(data.id)
        } else if DataType.self == A.RepositoryData.self {
            return accountList.used.readyValue?.contains(data.id)
        } else if DataType.self == E.RepositoryData.self {
            return assetList.used.readyValue?.contains(data.id)
        } else if DataType.self == S.RepositoryData.self {
            return stockList.used.readyValue?.contains(data.id)
        } else if DataType.self == C.RepositoryData.self {
            guard
                let categoryUsed = categoryList.used.readyValue,
                let categoryTree = categoryList.evalTree.readyValue
            else { return nil }
            return categoryUsed.contains(data.id) || categoryTree.childrenById[data.id] != nil
        } else if DataType.self == P.RepositoryData.self {
            return payeeList.used.readyValue?.contains(data.id)
        } else if DataType.self == G.RepositoryData.self {
            return tagList.used.readyValue?.contains(data.id)
        } else if DataType.self == D.RepositoryData.self {
            return attachmentList.used.readyValue?.contains(data.id)
        } else if DataType.self == BP.RepositoryData.self {
            return budgetPeriodList.used.readyValue?.contains(data.id)
        }
        return nil
    }

    func copy<DataType: DataProtocol>(_ data: inout DataType) {
        data.id = .void
        /**/   if var data1 = data as? CurrencyData {
            copyCurrency(&data1)
            data = data1 as! DataType
        } else if var data1 = data as? AccountData {
            copyAccount(&data1)
            data = data1 as! DataType
        } else if var data1 = data as? AssetData {
            copyAsset(&data1)
            data = data1 as! DataType
        } else if var data1 = data as? StockData {
            copyStock(&data1)
            data = data1 as! DataType
        } else if var data1 = data as? CategoryData {
            copyCategory(&data1)
            data = data1 as! DataType
        } else if var data1 = data as? PayeeData {
            copyPayee(&data1)
            data = data1 as! DataType
        } else if var data1 = data as? TagData {
            copyTag(&data1)
            data = data1 as! DataType
        } else if var data1 = data as? AttachmentData {
            copyAttachment(&data1)
            data = data1 as! DataType
        } else if var data1 = data as? BudgetPeriodData {
            copyBudgetPeriod(&data1)
            data = data1 as! DataType
        }
    }

    func update<DataType: DataProtocol>(_ data: inout DataType) -> String? {
        var error: String?
        /**/   if var data1 = data as? CurrencyData {
            error = updateCurrency(&data1)
            data = data1 as! DataType
        } else if var data1 = data as? AccountData {
            error = updateAccount(&data1)
            data = data1 as! DataType
        } else if var data1 = data as? AssetData {
            error = updateAsset(&data1)
            data = data1 as! DataType
        } else if var data1 = data as? StockData {
            error = updateStock(&data1)
            data = data1 as! DataType
        } else if var data1 = data as? CategoryData {
            error = updateCategory(&data1)
            data = data1 as! DataType
        } else if var data1 = data as? PayeeData {
            error = updatePayee(&data1)
            data = data1 as! DataType
        } else if var data1 = data as? TagData {
            error = updateTag(&data1)
            data = data1 as! DataType
        } else if var data1 = data as? AttachmentData {
            error = updateAttachment(&data1)
            data = data1 as! DataType
        } else if var data1 = data as? BudgetPeriodData {
            error = updateBudgetPeriod(&data1)
            data = data1 as! DataType
        } else {
            error = "* unknown data type"
        }
        return error
    }

    func delete<DataType: DataProtocol>(_ data: DataType) -> String? {
        /**/   if let data = data as? CurrencyData {
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
        } else if let data = data as? TagData {
            return deleteTag(data)
        } else if let data = data as? AttachmentData {
            return deleteAttachment(data)
        } else if let data = data as? BudgetPeriodData {
            return deleteBudgetPeriod(data)
        }
        return "* unknown data type"
    }
}

//
//  Validation.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension DataProtocol {
    @MainActor
    mutating func update(_ vm: ViewModel) -> String? {
        return "* not implemented"
    }

    @MainActor
    func delete(_ vm: ViewModel) -> String? {
        return "* not implemented"
    }
}

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
        } else if DataType.self == F.RepositoryData.self {
            return fieldList.used.readyValue?.contains(data.id)
        } else if DataType.self == D.RepositoryData.self {
            return attachmentList.used.readyValue?.contains(data.id)
        } else if DataType.self == BP.RepositoryData.self {
            return budgetPeriodList.used.readyValue?.contains(data.id)
        } else if DataType.self == B.RepositoryData.self {
            return budgetList.used.readyValue?.contains(data.id)
        } else if DataType.self == R.RepositoryData.self {
            return reportList.used.readyValue?.contains(data.id)
        }
        return nil
    }
}

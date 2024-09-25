//
//  MMEXDocument.swift
//  MMEX
//
//  Created 2024-09-24 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import SQLite

extension UTType {
    static var mmb: UTType { UTType(exportedAs: "com.guangong.mmex.mmb") }
}

struct MMEXDocument: FileDocument {
    static var readableContentTypes: [UTType] = [UTType.mmb]

    init() { }
    init(configuration: ReadConfiguration) throws { }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper()
    }
}

/*
extension MMEXDocument {
    static func create(at url: URL) {
        let dataManager = DataManager(databaseURL: url)
         dataManager.getInfotableRepository().create()
         dataManager.getCurrencyRepository().create()
         dataManager.getAccountRepository().create()
         dataManager.getAssetRepository().create()
         dataManager.getStockRepository().create()
         dataManager.getCategoryRepository().create()
         dataManager.getPayeeRepository().create()
         dataManager.getTransactionRepository().create()
         dataManager.getScheduledRepository().create()
    }
}
*/

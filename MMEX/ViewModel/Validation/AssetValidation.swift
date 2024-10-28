//
//  AssetValidation.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func updateAsset(_ data: inout AssetData) -> String? {
        return "* not implemented"
    }

    func deleteAsset(_ data: AssetData) -> String? {
        guard let assetUsed = assetList.used.readyValue else {
            return "* assetUsed is not loaded"
        }
        if assetUsed.contains(data.id) {
            return "* Asset #\(data.id) is used"
        }

        guard let e = E(env), let ax = AX(env) else {
            return "* Database is not available"
        }

        guard let assetAtt = assetList.att.readyValue else {
            return "* assetAtt is not loaded"
        }
        if assetAtt[data.id] != nil {
            guard ax.delete(refType: .asset, refId: data.id) else {
                return "* Cannot delete attachments for asset #\(data.id)"
            }
        }

        guard e.delete(data) else {
            return "* Cannot delete asset #\(data.id)"
        }

        return nil
    }
}

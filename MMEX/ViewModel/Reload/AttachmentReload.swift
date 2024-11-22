//
//  AttachmentReload.swift
//  MMEX
//
//  2024-11-05: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadAttachment(_ oldData: AttachmentData?, _ newData: AttachmentData?) async {
        log.trace("DEBUG: ViewModel.reloadAttachment(main=\(Thread.isMainThread))")

        if oldData?.refType == .account || newData?.refType == .account {
            reloadAccountAtt()
        }
        if oldData?.refType == .asset || newData?.refType == .asset {
            reloadAssetAtt()
        }
        if oldData?.refType == .stock || newData?.refType == .stock {
            reloadStockAtt()
        }
        if oldData?.refType == .payee || newData?.refType == .payee {
            reloadPayeeAtt()
        }

        // save isExpanded
        let groupIsExpanded: [Bool]? = attachmentGroup.readyValue?.map { $0.isExpanded }

        unloadAttachmentGroup()
        attachmentList.unload()

        if (oldData != nil) != (newData != nil) {
            attachmentList.count.unload()
        }

        if attachmentList.data.state.unloading() {
            if let newData {
                attachmentList.data.value[newData.id] = newData
            } else if let oldData {
                attachmentList.data.value[oldData.id] = nil
            }
            attachmentList.data.state.loaded()
        }

        attachmentList.order.unload()

        await loadAttachmentList()
        loadAttachmentGroup(choice: attachmentGroup.choice)

        // restore isExpanded
        if let groupIsExpanded { switch attachmentGroup.choice {
        default:
            if attachmentGroup.value.count == groupIsExpanded.count {
                for g in 0 ..< groupIsExpanded.count {
                    attachmentGroup.value[g].isExpanded = groupIsExpanded[g]
                }
            }
        } }

        log.info("INFO: ViewModel.reloadAttachment(main=\(Thread.isMainThread))")
    }
}

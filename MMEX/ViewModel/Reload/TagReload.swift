//
//  TagReload.swift
//  MMEX
//
//  2024-11-05: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadTagList(_ oldData: TagData?, _ newData: TagData?) async {
        log.trace("DEBUG: ViewModel.reloadTagList(main=\(Thread.isMainThread))")

        // save isExpanded
        let groupIsExpanded: [Bool]? = tagGroup.readyValue?.map { $0.isExpanded }

        unloadTagGroup()
        tagList.unload()

        if (oldData != nil) != (newData != nil) {
            tagList.count.unload()
        }

        if tagList.data.state.unloading() {
            if let newData {
                tagList.data.value[newData.id] = newData
            } else if let oldData {
                tagList.data.value[oldData.id] = nil
            }
            tagList.data.state.loaded()
        }

        tagList.order.unload()

        await reloadTagList()
        loadTagGroup(choice: tagGroup.choice)

        // restore isExpanded
        if let groupIsExpanded { switch tagGroup.choice {
        default:
            if tagGroup.value.count == groupIsExpanded.count {
                for g in 0 ..< groupIsExpanded.count {
                    tagGroup.value[g].isExpanded = groupIsExpanded[g]
                }
            }
        } }

        log.info("INFO: ViewModel.reloadTagList(main=\(Thread.isMainThread))")
    }
}

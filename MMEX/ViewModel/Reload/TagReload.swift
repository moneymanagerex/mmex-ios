//
//  TagReload.swift
//  MMEX
//
//  2024-11-05: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func reloadTag(_ pref: Preference, _ oldData: TagData?, _ newData: TagData?) async {
        log.trace("DEBUG: ViewModel.reloadTag(main=\(Thread.isMainThread))")

        // save isExpanded
        let groupIsExpanded: [Bool]? = tagGroup.readyValue?.map { $0.isExpanded }

        unloadTagGroup()
        tagList.unloadNone()

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

        await loadTagList(pref)
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

        log.info("INFO: ViewModel.reloadTag(main=\(Thread.isMainThread))")
    }

    func reloadTagUsed(_ pref: Preference, _ oldId: DataId?, _ newId: DataId?) {
        log.trace("DEBUG: ViewModel.reloadTagUsed(main=\(Thread.isMainThread), \(oldId?.value ?? 0), \(newId?.value ?? 0))")
        if let oldId, newId != oldId {
            if tagGroup.choice == .used {
                unloadTagGroup()
            }
            tagList.used.unload()
        } else if
            let tagUsed = tagList.used.readyValue,
            let newId, !tagUsed.contains(newId)
        {
            if tagGroup.choice == .used {
                unloadTagGroup()
            }
            if tagList.used.state.unloading() {
                tagList.used.value.insert(newId)
                tagList.used.state.loaded()
            }
        }
    }
}

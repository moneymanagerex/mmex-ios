//
//  SettingsList.swift
//  MMEX
//
//  2024-11-08: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

extension ViewModel {
    func loadSettingsList() async {
        guard settingsList.reloading() else { return }
        log.trace("DEBUG: ViewModel.loadSettingsList(main=\(Thread.isMainThread))")
        let ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        settingsList.loaded(ok: ok)
        if ok {
            log.info("INFO: ViewModel.loadSettingsList(main=\(Thread.isMainThread))")
        } else {
            log.debug("ERROR: ViewModel.loadSettingsList(main=\(Thread.isMainThread))")
            return
        }
    }

    func unloadSettingsList() {
        guard settingsList.unloading() else { return }
        log.trace("DEBUG: ViewModel.unloadSettingsList(main=\(Thread.isMainThread))")
        settingsList.unloaded()
    }
}

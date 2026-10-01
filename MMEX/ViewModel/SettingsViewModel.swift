//
//  SettingsViewModel.swift
//  MMEX
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var baseCurrencyId: DataId = .void
    @Published var defaultAccountId: DataId = .void
    @Published private(set) var alertMessage: String?

    var isAlertPresented: Bool { alertMessage != nil }

    func load(from appModel: ViewModel, preference: Preference) async {
        await appModel.loadSettingsList(preference)
        baseCurrencyId = appModel.infotableList.baseCurrencyId.value
        defaultAccountId = appModel.infotableList.defaultAccountId.value
    }

    func refresh(from appModel: ViewModel, preference: Preference) async {
        appModel.unloadAll()
        await load(from: appModel, preference: preference)
    }

    func currencyOptions(from list: CurrencyList) -> [DataId] {
        var options: [DataId] = [.void]
        var hasSelectedCurrency = baseCurrencyId.isVoid
        for id in list.order.readyValue ?? [] where id == baseCurrencyId || list.used.readyValue?.contains(id) == true {
            options.append(id)
            if id == baseCurrencyId { hasSelectedCurrency = true }
        }
        if !hasSelectedCurrency { options.append(baseCurrencyId) }
        return options
    }

    func accountOptions(from list: AccountList) -> [DataId] {
        var options: [DataId] = [.void]
        var hasSelectedAccount = defaultAccountId.isVoid
        for id in list.order.readyValue ?? [] where id == defaultAccountId || list.data.readyValue?[id]?.status == .open {
            options.append(id)
            if id == defaultAccountId { hasSelectedAccount = true }
        }
        if !hasSelectedAccount { options.append(defaultAccountId) }
        return options
    }

    func updateBaseCurrency(using appModel: ViewModel) async {
        guard baseCurrencyId != appModel.infotableList.baseCurrencyId.value else { return }
        if let error = appModel.updateSettings(baseCurrencyId: baseCurrencyId) {
            baseCurrencyId = appModel.infotableList.baseCurrencyId.value
            alertMessage = error
            return
        }
        await appModel.reloadSettings(baseCurrencyId: baseCurrencyId)
    }

    func updateDefaultAccount(using appModel: ViewModel) async {
        guard defaultAccountId != appModel.infotableList.defaultAccountId.value else { return }
        if let error = appModel.updateSettings(defaultAccountId: defaultAccountId) {
            defaultAccountId = appModel.infotableList.defaultAccountId.value
            alertMessage = error
            return
        }
        await appModel.reloadSettings(defaultAccountId: defaultAccountId)
    }

    func dismissAlert() {
        alertMessage = nil
    }
}

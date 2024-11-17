//
//  AccountSearch.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct AccountSearch: SearchProtocol {
    var area: [SearchArea<AccountData>] = [
        ("Name",       true,  {[ $0.name ]}, nil),
        ("Currency",   false, nil, { vm, data in [
            vm.currencyList.name.readyValue?[data.currencyId] ?? ""
        ] } ),
        ("Notes",      false, {[ $0.notes ]}, nil),
        ("Attachment", false, nil, { vm, data in
            (vm.accountList.att.readyValue?[data.id]?.map { $0.description } ?? []) +
            (vm.accountList.att.readyValue?[data.id]?.map { $0.filename } ?? [])
        } ),
        ("Other",      false, {[ $0.num, $0.heldAt, $0.website, $0.contactInfo, $0.accessInfo ]}, nil),
    ]
    var key: String = ""
}

extension ViewModel {
    func accountGroupIsVisible(_ g: Int, search: AccountSearch
    ) -> Bool? {
        guard
            let listData  = accountList.data.readyValue,
            let groupData = accountGroup.readyValue
        else { return nil }

        if search.isEmpty {
            return switch accountGroup.choice {
            case .type, .currency: !groupData[g].dataId.isEmpty
            default: true
            }
        }
        return groupData[g].dataId.first(where: { search.match(self, listData[$0]!) }) != nil
    }

    func searchAccountGroup(search: AccountSearch, expand: Bool = false) {
        guard accountGroup.state == .ready else { return }
        log.trace("DEBUG: ViewModel.searchAccountGroup()")
        for g in 0 ..< accountGroup.value.count {
            guard let isVisible = accountGroupIsVisible(g, search: search) else { return }
            //log.debug("DEBUG: ViewModel.searchAccountGroup(): \(g) = \(isVisible)")
            accountGroup.value[g].isVisible = isVisible
            if (expand || !search.isEmpty) && isVisible {
                accountGroup.value[g].isExpanded = true
            }
        }
    }
}

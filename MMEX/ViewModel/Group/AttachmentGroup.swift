//
//  AttachmentGroup.swift
//  MMEX
//
//  2024-11-05: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum AttachmentGroupChoice: String, GroupChoiceProtocol {
    case all     = "All"
    case refType = "Ref. Type"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct AttachmentGroup: GroupProtocol {
    typealias MainRepository = AttachmentRepository
    typealias GroupChoice    = AttachmentGroupChoice
    typealias ValueType      = [GroupData]
    let idleValue: ValueType = []

    @StoredPreference var choice: GroupChoice = .defaultValue
    var search: Bool = false
    var state: LoadState = .init()
    var value: ValueType
    
    init() {
        self.value = idleValue
        self.$choice = "manage.group.attachment"
    }

    static let groupRefType: [RefType] = [
        .account, .asset, .stock, .payee,
        .transaction, .transactionSplit,
        .scheduled, .scheduledSplit
    ]
}

extension ViewModel {
    func loadAttachmentGroup(choice: AttachmentGroupChoice) {
        guard
            let listData  = attachmentList.data.readyValue,
            let listOrder = attachmentList.order.readyValue
        else { return }

        guard attachmentGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadAttachmentGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        attachmentGroup.choice = choice
        attachmentGroup.search = false

        switch choice {
        case .all:
            attachmentGroup.append("All", listOrder, true, true)
        case .refType:
            let dict = Dictionary(grouping: listOrder) { listData[$0]!.refType }
            for g in AttachmentGroup.groupRefType {
                attachmentGroup.append(g.rawValue, dict[g] ?? [], dict[g] != nil, true)
            }
        }

        attachmentGroup.state.loaded()
        log.info("INFO: ViewModel.loadAttachmentGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
    }
}

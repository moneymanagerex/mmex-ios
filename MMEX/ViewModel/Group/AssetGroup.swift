//
//  AssetGroup.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

enum AssetGroupChoice: String, GroupChoiceProtocol {
    case all        = "All"
    case used       = "Used"
    case status     = "Status"
    case type       = "Type"
    case currency   = "Currency"
    case attachment = "Attachment"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct AssetGroup: GroupProtocol {
    typealias MainRepository = AssetRepository
    typealias GroupChoice    = AssetGroupChoice
    let loadName: String = "Group\(MainRepository.repositoryName)"
    let idleValue: ValueType = []

    var choice: GroupChoice = .defaultValue
    var state: LoadState = .init()
    var value: ValueType
    
    init() {
        self.value = idleValue
    }

    static let groupUsed: [Bool] = [
        true, false
    ]

    static let groupStatus: [AssetStatus] = [
        .open, .closed
    ]

    static let groupType: [AssetType] = [
        .property, .automobile, .household, .art, .jewellery, .cash, .other
    ]

    var groupCurrency: [DataId] = []

    static let groupAttachment: [Bool] = [
        true, false
    ]
}

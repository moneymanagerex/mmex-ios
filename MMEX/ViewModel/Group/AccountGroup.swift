//
//  AccountGroup.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

enum AccountGroupChoice: String, GroupChoiceProtocol {
    case all        = "All"
    case used       = "Used"
    case favorite   = "Favorite"
    case status     = "Status"
    case type       = "Type"
    case currency   = "Currency"
    case attachment = "Attachment"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct AccountGroup: GroupProtocol {
    typealias MainRepository = AccountRepository
    typealias GroupChoice    = AccountGroupChoice
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

    static let groupFavorite: [AccountFavorite] = [
        .boolTrue, .boolFalse
    ]

    static let groupStatus: [AccountStatus] = [
        .open, .closed
    ]

    static let groupType: [AccountType] = [
        .checking, .creditCard, .cash, .loan, .term, .asset, .shares, .investment
    ]

    var groupCurrency: [DataId] = []

    static let groupAttachment: [Bool] = [
        true, false
    ]
}

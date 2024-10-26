//
//  StockGroup.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

enum StockGroupChoice: String, GroupChoiceProtocol {
    case all        = "All"
    case used       = "Used"
    case account    = "Account"
    case attachment = "Attachment"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct StockGroup: GroupProtocol {
    typealias MainRepository = StockRepository
    typealias GroupChoice    = StockGroupChoice

    var choice: GroupChoice = .defaultValue
    var state: LoadState = .init()
    var value: [GroupData] = []

    static let groupUsed: [Bool] = [
        true, false
    ]

    var groupAccount: [DataId] = []

    static let groupAttachment: [Bool] = [
        true, false
    ]
}

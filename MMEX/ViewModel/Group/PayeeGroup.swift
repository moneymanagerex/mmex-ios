//
//  PayeeGroup.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

enum PayeeGroupChoice: String, GroupChoiceProtocol {
    case all        = "All"
    case used       = "Used"
    case active     = "Active"
    case category   = "Category"
    case attachment = "Attachment"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct PayeeGroup: GroupProtocol {
    typealias MainRepository = PayeeRepository
    typealias GroupChoice    = PayeeGroupChoice
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

    static let groupActive: [Bool] = [
        true, false
    ]

    var groupCategory: [DataId] = []

    static let groupAttachment: [Bool] = [
        true, false
    ]
}

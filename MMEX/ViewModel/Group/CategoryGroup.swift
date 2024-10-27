//
//  CategoryGroup.swift
//  MMEX
//
//  2024-10-27: Created by George Ef (george.a.ef@gmail.com)
//

enum CategoryGroupChoice: String, GroupChoiceProtocol {
    case all        = "All"
    case used       = "Used"
    case active     = "Active"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct CategoryGroup: GroupProtocol {
    typealias MainRepository = CategoryRepository
    typealias GroupChoice    = CategoryGroupChoice
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
}

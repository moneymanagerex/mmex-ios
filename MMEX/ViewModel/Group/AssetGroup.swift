//
//  AssetGroup.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

enum AssetGroupChoice: String, GroupChoiceProtocol {
    case all      = "All"
    case used     = "Used"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct AssetGroup: GroupProtocol {
    typealias MainRepository = AssetRepository
    typealias GroupChoice    = AssetGroupChoice

    var choice: GroupChoice = .defaultValue
    var state: LoadState = .init()
    var value: [GroupData] = []
}

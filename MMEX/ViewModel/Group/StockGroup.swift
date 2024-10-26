//
//  StockGroup.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

enum StockGroupChoice: String, GroupChoiceProtocol {
    case all      = "All"
    case used     = "Used"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all]
}

struct StockGroup: GroupProtocol {
    typealias MainRepository = StockRepository
    typealias GroupChoice    = StockGroupChoice

    var choice: GroupChoice = .defaultValue
    var state: LoadState = .init()
    var value: [GroupData] = []
}

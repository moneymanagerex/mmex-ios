//
//  RpositoryViewModel.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum RepositoryLoadState: Int, Identifiable, Equatable {
    case error
    case idle
    case loading
    case ready
    var id: Self { self }
}

struct RepositoryLoad<LoadData: Copyable>: Copyable {
    var state: RepositoryLoadState = .idle
    var data: LoadData
}

extension RepositoryLoad {
    init(_ data: LoadData) {
        self.init(data: data)
    }
}

protocol RepositoryGroupProtocol: EnumCollateNoCase, Hashable
where Self.AllCases: RandomAccessCollection {
    static var isSingleton: Set<Self> { get }
}

struct RepositoryGroup<Group: RepositoryGroupProtocol> {
    var state: RepositoryLoadState = .idle
    var group: Group = Group.defaultValue
    var groupDataId     : [[DataId]] = []
    var groupIsVisible  : [Bool]     = []
    var groupIsExpanded : [Bool]     = []
}

typealias RepositorySearchArea<RepositoryData: DataProtocol> = (
    name: String,
    isSelected: Bool,
    values: [(RepositoryData) -> String]
)

protocol RepositorySearchProtocol: Copyable {
    associatedtype RepositoryData: DataProtocol
    var area: [RepositorySearchArea<RepositoryData>] { get set }
    var key: String { get set }
}

extension RepositorySearchProtocol {
    var prompt: String {
        "Search in " + area.compactMap { $0.isSelected ? $0.name : nil }.joined(separator: ", ")
    }
    var isEmpty: Bool { key.isEmpty }
    func match(_ data: RepositoryData) -> Bool {
        if key.isEmpty { return true }
        for i in 0 ..< area.count {
            guard area[i].isSelected else { continue }
            if area[i].values.first(
                where: { $0(data).localizedCaseInsensitiveContains(key) }
            ) != nil {
                return true
            }
        }
        return false
    }
}

@MainActor
protocol RepositoryViewModelProtocol: AnyObject, ObservableObject {
    associatedtype RepositoryData   : DataProtocol
    associatedtype RepositoryGroup  : RepositoryGroupProtocol
    associatedtype RepositorySearch : RepositorySearchProtocol
    where RepositorySearch.RepositoryData == Self.RepositoryData

    var dataState        : RepositoryLoadState      { get set }
    var dataById         : [DataId: RepositoryData] { get set }
    var usedId           : Set<DataId>              { get set }

    var group            : RepositoryGroup          { get set }
    var groupState       : RepositoryLoadState      { get set }
    var groupDataId      : [[DataId]]               { get set }

    var search           : RepositorySearch         { get set }
    var groupIsVisible   : [Bool]                   { get set }
    var groupIsExpanded  : [Bool]                   { get set }

    static var newData: RepositoryData { get }

    // load `dataById`; set `dataState` to `.ready` or `.error`
    // prerequisites: `dataState == .idle && groupState == .idle`
    func loadData(env: EnvironmentManager) async

    // set `dataState` to `.idle`
    // prerequisites: `groupState == .idle`
    func unloadData()

    // create `groupDataId`; initialize `groupIsVisible`, `groupIsExpanded`
    // set `group`; set `groupState` to `.ready` or `.error`
    // prerequisites: `dataState == .ready`
    func loadGroup(env: EnvironmentManager, group: RepositoryGroup)// async

    // set `groupState` to `.idle`
    func unloadGroup()

    // set `groupIsVisible`, `groupIsExpanded`; set `groupState` back to `.ready`
    // prerequisites: `groupState == .ready`
    func searchGroup(expand: Bool)

    func groupIsVisible(_ groupId: Int) -> Bool
}

extension RepositoryViewModelProtocol {
    func preloaded(env: EnvironmentManager, group: RepositoryGroup) -> Self {
        Task {
            await loadData(env: env)
            loadGroup(env: env, group: group)
            searchGroup()
        }
        return self
    }

    func unloadData() {
        log.trace("DEBUG: RepositoryViewModelProtocol.unloadData(): main=\(Thread.isMainThread)")
        if dataState == .idle { return }
        if groupState != .idle { unloadGroup() }
        dataState = .idle
        dataById.removeAll()
    }

    func unloadGroup() {
        log.trace("DEBUG: RepositoryViewModelProtocol.unloadGroup(): main=\(Thread.isMainThread)")
        if groupState == .idle { return }
        groupState = .idle
        groupDataId = []
    }

    func dataIsVisible(_ data: RepositoryData) -> Bool {
        search.match(data)
    }

    func dataIsVisible(_ dataId: DataId) -> Bool {
        search.match(dataById[dataId]!)
    }

    func groupIsVisible(_ groupId: Int) -> Bool {
        return !search.isEmpty || groupDataId[groupId].first(
            where: { dataIsVisible($0) }
        ) != nil
    }

    func searchGroup(expand: Bool = false) {
        log.trace("DEBUG: RepositoryViewModelProtocol.searchGroup()")
        guard groupState == .ready else { return }
        groupState = .loading
        for g in 0 ..< groupDataId.count {
            let isVisible = groupIsVisible(g)
            log.debug("DEBUG: RepositoryViewModelProtocol.searchGroup(): \(g) = \(isVisible)")
            if (expand || !self.search.isEmpty) && isVisible {
                groupIsExpanded[g] = true
            }
            groupIsVisible[g] = isVisible
        }
        groupState = .ready
    }
}

class RepositoryViewModel: ObservableObject {
    var currencyCount         : RepositoryLoad<Int>                    = .init(0)
    var currencyData          : RepositoryLoad<[DataId: CurrencyData]> = .init([:])
    var currencyOrder         : RepositoryLoad<[DataId]>               = .init([])
    var currencyUsed          : RepositoryLoad<Set<DataId>>            = .init([])
    var currencyOrderWithName : RepositoryLoad<[(DataId, String)]>     = .init([])

    var accountCount            : RepositoryLoad<Int>                   = .init(0)
    var accountData             : RepositoryLoad<[DataId: AccountData]> = .init([:])
    var accountCountAttachments : RepositoryLoad<[DataId: Int]>         = .init([:])
    var accountOrder            : RepositoryLoad<[DataId]>              = .init([])
    var accountUsed             : RepositoryLoad<Set<DataId>>           = .init([])

    //var currencyGroup : RepositoryGroup<CurrencyGroup> = .init()
    var accountGroup  : RepositoryGroup<AccountGroup>  = .init()
}

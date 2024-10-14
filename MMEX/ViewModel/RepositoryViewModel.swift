//
//  RpositoryViewModel.swift
//  MMEX
//
//  2024-10-11: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum RepositoryLoadState: Int, Identifiable, Equatable {
    case idle
    case loading
    case ready
    case error
    var id: Self { self }
}

protocol RepositoryGroupByProtocol: EnumCollateNoCase, Hashable
where Self.AllCases: RandomAccessCollection {
}

enum RepositorySearchMode: String, EnumCollateNoCase, Hashable {
    case simple   = "Search"
    case advanced = "Adv. Search"
    static var defaultValue = Self.simple
}

protocol RepositorySearchProtocol: Copyable {
    associatedtype RepositoryData: DataProtocol
    var mode: RepositorySearchMode { get set }
    var key: String { get set }
    var isEmpty: Bool { get }
    func match(_ data: RepositoryData) -> Bool
}

@MainActor
protocol RepositoryViewModelProtocol: AnyObject, Observable {
    associatedtype RepositoryData    : DataProtocol
    associatedtype RepositoryGroupBy : RepositoryGroupByProtocol
    associatedtype RepositorySearch  : RepositorySearchProtocol
    where RepositorySearch.RepositoryData == Self.RepositoryData

    var env         : EnvironmentManager       { get }
    var dataState   : RepositoryLoadState      { get set }
    var dataById    : [DataId: RepositoryData] { get set }

    var groupBy     : RepositoryGroupBy        { get set }
    var groupState  : RepositoryLoadState      { get set }
    var groupDataId : [[DataId]]               { get set }

    var search          : RepositorySearch     { get set }
    var groupIsVisible  : [Bool]               { get set }
    var groupIsExpanded : [Bool]               { get set }

    static var newData: RepositoryData { get }

    init(env: EnvironmentManager)

    // load `dataById`; set `dataState` to `.ready` or `.error`
    // prerequisites: `dataState == .idle && groupState == .idle`
    func loadData() async

    // set `dataState` to `.idle`
    // prerequisites: `groupState == .idle`
    func unloadData()

    // create `groupDataId`; initialize `groupIsVisible`, `groupIsExpanded`
    // set `groupBy`; set `groupState` to `.ready` or `.error`
    // prerequisites: `dataState == .ready`
    func loadGroup(_ groupBy: RepositoryGroupBy)// async //-> RepositoryLoadState

    // set `groupState` to `.idle`
    func unloadGroup()

    // set `search.mode`, `search.key`
    func simpleSearch(with key: String)

    // set `groupIsVisible`, `groupIsExpanded`; set `groupState` back to `.ready`
    // prerequisites: `groupState == .ready`
    func searchGroup(expand: Bool)

    func groupIsVisible(_ groupId: Int) -> Bool
}

extension RepositoryViewModelProtocol {
    func unloadData() {
        log.trace("DEBUG: RepositoryViewModelProtocol.unloadData(): main=\(Thread.isMainThread)")
        if groupState != .idle { unloadGroup() }
        dataState = .idle
        dataById.removeAll()
    }

    func unloadGroup() {
        log.trace("DEBUG: RepositoryViewModelProtocol.unloadGroup(): main=\(Thread.isMainThread)")
        groupState = .idle
        groupDataId = []
    }

    func dataIsVisible(_ data: RepositoryData) -> Bool {
        search.match(data)
    }

    func dataIsVisible(_ dataId: DataId) -> Bool {
        search.match(dataById[dataId]!)
    }

    func simpleSearch(with key: String) {
        search.mode = .simple
        search.key = key
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

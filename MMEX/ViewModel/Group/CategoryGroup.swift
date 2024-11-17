//
//  CategoryGroup.swift
//  MMEX
//
//  2024-11-17: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

enum CategoryGroupChoice: String, GroupChoiceProtocol {
    case all       = "All"
    case used      = "Used"
    case notUsed   = "Not Used"
    case active    = "Active"
    case notActive = "Not Active"
    static let defaultValue = Self.all
    static let isSingleton: Set<Self> = [.all, .used, .notUsed, .active, .notActive]
}

enum CategoryGroupMember: Int {
    case boolFalse     // this node and all its descendants do not belong to group/search subtree
    case boolTrue      // this node belongs to group/search subtree
    case intermediate  // this node does not belong to group/search subtree, but some descendant does
}

struct CategoryGroupNode {
    // group is a subtree of category tree; search is a subtree of group tree
    var memberInGroup  : CategoryGroupMember = .boolFalse  // this node belongs to group subtree
    var memberInSearch : CategoryGroupMember = .boolFalse  // this node belongs to search subtree
    var countInGroup   : Int = 0   // number of descendants in group subtree
    var countInSearch  : Int = 0   // number of descendants in search subtree
    var isVisible      = false     // applicable if member != .boolFalse
    var isExpanded     = false     // applicable if count > 0
}

extension CategoryGroupNode {
    func member(search: Bool) -> CategoryGroupMember { search ? memberInSearch : memberInGroup }
    func count(search: Bool) -> Int { search ? countInSearch : countInGroup }
}

struct CategoryGroup: GroupProtocol {
    typealias MainRepository = CategoryRepository
    typealias GroupChoice    = CategoryGroupChoice
    typealias ValueType      = [CategoryGroupNode]  // same size as CategoryNode.order
    let idleValue: ValueType = []

    @Preference var choice: GroupChoice = .defaultValue
    var state: LoadState = .init()
    var value: ValueType

    init() {
        self.value = idleValue
    }
}

extension ViewModel {
    func loadCategoryGroup(choice: CategoryGroupChoice) {
        guard
            let listData = categoryList.data.readyValue,
            let listUsed = categoryList.used.readyValue,
            let evalTree = categoryList.evalTree.readyValue
        else { return }

        guard categoryGroup.state.loading() else { return }
        log.trace("DEBUG: ViewModel.loadCategoryGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
        
        categoryGroup.choice = choice

        let isMember: (DataId) -> Bool = switch choice {
        case .all       : { _ in true }
        case .used      : { listUsed.contains($0) }
        case .notUsed   : { !listUsed.contains($0) }
        case .active    : { listData[$0]?.active == true }
        case .notActive : { listData[$0]?.active == false }
        }

        var value = evalTree.order.map { node in CategoryGroupNode(
            memberInGroup: isMember(node.dataId) ? .boolTrue : .boolFalse
        ) }
        for i in 0 ..< value.count {
            guard value[i].memberInGroup == .boolTrue else { continue }
            var p = evalTree.order[i].parent
            while p != -1, value[p].memberInGroup == .boolFalse {
                value[p].memberInGroup = .intermediate
                p = evalTree.order[p].parent
            }
        }
        
        var stack: [(Int, Int)] = []  // index, current count
        var i = 0
        while i < value.count {
            let node = evalTree.order[i]
            while stack.count > node.level {
                let (p, count) = stack.popLast()!
                value[p].countInGroup = count
                if !stack.isEmpty {
                    stack[stack.endIndex - 1].1 += count + 1
                }
            }
            // assertion: stack.count == node.level
            if value[i].memberInGroup == .boolFalse {
                i = evalTree.order[i].next
            } else {
                stack.append((i, 0))
                value[i].isVisible = node.level == 0
                i += 1
            }
        }
        while !stack.isEmpty {
            let (p, count) = stack.popLast()!
            value[p].countInGroup = count
            if !stack.isEmpty {
                stack[stack.endIndex - 1].1 += count + 1
            }
        }

        if false { print(
            "DEBUG: ViewModel.loadCategoryGroup(\(choice.rawValue)): value:\n" +
            value.enumerated().map { (i, groupNode) in
                let treeNode = evalTree.order[i]
                let (l, id) = (treeNode.level, treeNode.dataId)
                let m = switch groupNode.memberInGroup {
                case .boolFalse: "N"; case .boolTrue: "Y"; case .intermediate: "int"
                }
                let c = groupNode.countInGroup
                let v = groupNode.isVisible  ? "V" : ""
                let e = groupNode.isExpanded ? "E" : ""
                let name = listData[id]!.name
                return "  \(i): l=\(l), m=\(m), c=\(c), ve=\(v)\(e), id=\(id) (\(name))\n"
            }.joined(separator: ""),
            terminator: ""
        ) }

        categoryGroup.value = value
        categoryGroup.state.loaded()
        log.info("INFO: ViewModel.loadCategoryGroup(\(choice.rawValue), main=\(Thread.isMainThread))")
    }

    func unloadCategoryGroup() {
        categoryGroup.unload()
    }
}

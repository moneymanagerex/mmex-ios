//
//  CategoryList.swift
//  MMEX
//
//  2024-10-27: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct CategoryListTree {
    var childrenById : [DataId: [DataId]] = [:]  // parentId or -1 -> [childId] (preserving order)
    var indexById    : [DataId: Int]      = [:]  // dataId -> index in order
    var order        : [CategoryListNode]     = []   // pre-order of category tree (one node per dataId)
}

struct CategoryListNode {
    var level  : Int     // depth of this node in tree, starting from 0 for root nodes
    var parent : Int     // index of the parent node in tree, or -1 if this is a root node
    var next   : Int     // next index for which order[next].level <= order[this].level
    var dataId : DataId  // the category id of this node
}

struct CategoryList: ListProtocol {
    typealias MainRepository = CategoryRepository

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var used  : LoadMainUsed<MainRepository>  = .init()
    var order : LoadMainOrder<MainRepository> = .init(
        order: [MainRepository.col_parentId, MainRepository.col_name]
    )

    var evalPath : LoadCategoryPath = .init()
    var evalTree : LoadCategoryTree = .init()
    var evalUsed : LoadCategoryUsed = .init()
}

extension ViewModel {
    func loadCategoryList(_ pref: Preference) async {
        guard categoryList.reloading() else { return }
        var ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(&taskGroup, keyPath: \Self.categoryList.data),
                load(&taskGroup, keyPath: \Self.categoryList.used),
                load(&taskGroup, keyPath: \Self.categoryList.order),
                // auxiliary
                //load(&taskGroup, keyPath: \Self.infotableList.categoryDelimiter),
            ].allSatisfy { $0 }
            return await taskGroupOk(taskGroup, ok)
        }
        if ok { ok = await withTaskGroup(of: Bool.self) { taskGroup -> Bool in
            let ok = [
                load(pref, &taskGroup, keyPath: \Self.categoryList.evalPath),
                load(pref, &taskGroup, keyPath: \Self.categoryList.evalTree),
                load(pref, &taskGroup, keyPath: \Self.categoryList.evalUsed),
            ].allSatisfy({$0})
            return await taskGroupOk(taskGroup, ok)
        } }
        categoryList.loaded(ok: ok)
    }

    func unloadCategoryList() {
        guard categoryList.reloading() else { return }
        categoryList.evalPath.unload()
        categoryList.evalTree.unload()
        categoryList.evalUsed.unload()
        categoryList.count.unload()
        categoryList.data.unload()
        categoryList.used.unload()
        categoryList.order.unload()
        categoryList.unloaded()
    }
}

struct LoadCategoryPath: LoadEvalProtocol {
    typealias ValueType = [DataId: String]
    let loadName: String = "Path(\(CategoryRepository.repositoryName))"
    let idleValue: ValueType = [:]

    var state: LoadState = .init()
    var value: ValueType

    init() {
        self.value = idleValue
    }

    nonisolated func evalValue(pref: Preference, vm: ViewModel) async -> ValueType? {
        guard let data = await vm.categoryList.data.readyValue else { return nil }
        return vm.evalCategoryPath(data: data, sep: pref.theme.categoryDelimiter)
    }
}

struct LoadCategoryTree: LoadEvalProtocol {
    typealias ValueType = CategoryListTree
    let loadName: String = "Tree(\(CategoryRepository.repositoryName))"
    let idleValue: ValueType = CategoryListTree()
    var state: LoadState = .init()
    var value: ValueType

    init() {
        self.value = idleValue
    }

    nonisolated func evalValue(pref: Preference, vm: ViewModel) async -> ValueType? {
        guard
            let data  = await vm.categoryList.data.readyValue,
            let order = await vm.categoryList.order.readyValue
        else { return nil }
        return vm.evalCategoryTree(data: data, order: order)
    }
}

struct LoadCategoryUsed: LoadEvalProtocol {
    typealias ValueType = Set<DataId>
    let loadName: String = "UsedClosure(\(CategoryRepository.repositoryName))"
    let idleValue: ValueType = []
    var state: LoadState = .init()
    var value: ValueType

    init() {
        self.value = idleValue
    }

    nonisolated func evalValue(pref: Preference, vm: ViewModel) async -> ValueType? {
        guard
            let data = await vm.categoryList.data.readyValue,
            let used = await vm.categoryList.used.readyValue
        else { return nil }
        return vm.evalCategoryUsedClosure(data: data, used: used)
    }
}

extension ViewModel {
    nonisolated func evalCategoryPath(
        data: [DataId: CategoryData],
        sep: String = ":"
    ) -> [DataId: String] {
        var path: [DataId: String] = [:]
        for id in data.keys {
            var stack: [DataId] = []
            var id1 = id
            while !id1.isVoid, path[id1] == nil, let pid1 = data[id1]?.parentId {
                stack.append(id1)
                id1 = pid1
            }
            while let id1 = stack.popLast(), let name = data[id1]?.name {
                if let pid1 = data[id1]?.parentId, !pid1.isVoid, let path1 = path[pid1] {
                    path[id1] = path1 + sep + name
                } else {
                    path[id1] = name
                }
            }
        }
        return path
    }

    nonisolated func evalCategoryTree(
        data: [DataId: CategoryData],
        order: [DataId]
    ) -> CategoryListTree {
        let childrenById = Dictionary(grouping: order) {
            data[$0]?.parentId ?? .void
        }

        var indexById: [DataId: Int] = [:]
        var treeOrder: [CategoryListNode] = []
        var stack: [(Int, Int)] = [(-1, 0)]  // parent index, index in childrenById[parentId]
        var last: [Int] = []  // last index in order for each level
        while !stack.isEmpty {
            let level = stack.endIndex - 1
            let (parentIndex, childrenIndex) = stack[level]
            let parentId = parentIndex != -1 ? treeOrder[parentIndex].dataId : .void
            guard let children = childrenById[parentId], childrenIndex < children.count else {
                _ = stack.popLast()
                continue
            }
            let childId = children[childrenIndex]
            treeOrder.append(CategoryListNode(
                level: level, parent: parentIndex, next: -1, dataId: childId
            ) )
            let childIndex = treeOrder.endIndex - 1
            stack[level].1 += 1
            if childrenById[childId] != nil {
                stack.append((childIndex, 0))
            }
            indexById[childId] = childIndex
            while last.count > level {
                let lastIndex = last.popLast()!
                treeOrder[lastIndex].next = childIndex
            }
            // assertion: last.count == level
            last.append(childIndex)
        }
        
        for lastIndex in last {
            treeOrder[lastIndex].next = treeOrder.endIndex
        }

        if false { print(
            "DEBUG: ViewModel.evalCategoryTree(): order:\n" +
            treeOrder.enumerated().map { (i, node) in
                let (l, p, n, id) = (node.level, node.parent, node.next, node.dataId)
                let name = data[id]!.name
                return "  \(i): l=\(l), p=\(p), n=\(n), id=\(id) (\(name))\n"
            }.joined(separator: "") + "\n" +
            "DEBUG: ViewModel.evalCategoryTree(): indexById:\n" +
            indexById.keys.sorted(by: { $0.value < $1.value }).map {
                "  \($0.value) -> \(indexById[$0]!)\n"
            }.joined(separator: ""),
            terminator: ""
        ) }

        return CategoryListTree(
            childrenById : childrenById,
            indexById    : indexById,
            order        : treeOrder
        )
    }

    nonisolated func evalCategoryUsedClosure(
        data: [DataId: CategoryData],
        used: Set<DataId>
    ) -> Set<DataId> {
        var usedClosure: Set<DataId> = []
        for id in data.keys {
            guard used.contains(id) else { continue }
            var pid = id
            while !pid.isVoid, !usedClosure.contains(pid) {
                usedClosure.insert(pid)
                pid = data[pid]?.parentId ?? .void
            }
        }
        return usedClosure
    }
}

extension CategoryListTree {
    func firstChild(underIndex index: Int) -> Int? {
        guard index >= 0 && index < order.count else { return nil }
        guard index + 1 < order.count else { return -1 }
        return order[index + 1].level > order[index].level ? (index + 1) : -1
    }

    func descendantsCount(underIndex index: Int) -> Int? {
        guard index >= 0 && index < order.count else { return nil }
        return order[index].next - index - 1
    }

    func descendantsCount(underId dataId: DataId) -> Int? {
        guard let index = indexById[dataId] else { return nil }
        return descendantsCount(underIndex: index)
    }
}

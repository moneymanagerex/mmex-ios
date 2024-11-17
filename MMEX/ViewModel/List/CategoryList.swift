//
//  CategoryList.swift
//  MMEX
//
//  2024-10-27: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

struct CategoryNode {
    var level  : Int     // starting from 0 for root nodes
    var next   : Int     // next index in tree for which next.level <= this.level, or -1
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
    var path  : LoadCategoryPath              = .init()
    var tree  : LoadCategoryTree              = .init()
}

extension ViewModel {
    func loadCategoryList() async {
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
                load(&taskGroup, keyPath: \Self.categoryList.path),
                load(&taskGroup, keyPath: \Self.categoryList.tree),
            ].allSatisfy({$0})
            return await taskGroupOk(taskGroup, ok)
        } }
        categoryList.loaded(ok: ok)
    }

    func unloadCategoryList() {
        guard categoryList.unloading() else { return }
        categoryList.data.unload()
        categoryList.used.unload()
        categoryList.order.unload()
        categoryList.path.unload()
        categoryList.tree.unload()
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

    nonisolated func evalValue(env: EnvironmentManager, vm: ViewModel) async -> ValueType? {
        guard let data = await vm.categoryList.data.readyValue else { return nil }
        return await vm.evalCategoryPath(data: data, sep: env.theme.categoryDelimiter)
    }
}

struct LoadCategoryTree: LoadEvalProtocol {
    typealias ValueType = (node: [CategoryNode], index: [DataId: Int])
    let loadName: String = "Tree(\(CategoryRepository.repositoryName))"
    let idleValue: ValueType = (node: [], index: [:])
    var state: LoadState = .init()
    var value: ValueType

    init() {
        self.value = idleValue
    }

    nonisolated func evalValue(env: EnvironmentManager, vm: ViewModel) async -> ValueType? {
        guard
            let data  = await vm.categoryList.data.readyValue,
            let order = await vm.categoryList.order.readyValue
        else { return nil }
        return await vm.evalCategoryTree(data: data, order: order)
    }
}

extension ViewModel {
    nonisolated func evalCategoryPath(
        data: [DataId: CategoryData],
        sep: String = ":"
    ) async -> [DataId: String] {
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
    ) async -> (node: [CategoryNode], index: [DataId: Int]) {
        let childrenById = Dictionary(grouping: order) {
            data[$0]?.parentId ?? .void
        }
        var node: [CategoryNode] = []
        var index: [DataId: Int] = [:]
        var stack: [(DataId, Int)] = [(.void, 0)]  // parentId, index in childrenById[parentId]
        var last: [Int] = []  // last index in tree for each level
        while !stack.isEmpty {
            let level = stack.endIndex - 1
            let (parentId, childIndex) = stack[level]
            guard let children = childrenById[parentId], childIndex < children.count else {
                _ = stack.popLast()
                continue
            }
            let dataId = children[childIndex]
            node.append(CategoryNode(
                level: level, next: -1, dataId: dataId
            ) )
            stack[level].1 += 1
            if childrenById[dataId] != nil {
                stack.append((dataId, 0))
            }
            let nodeIndex = node.endIndex - 1
            index[dataId] = nodeIndex
            while last.count > level {
                let lastIndex = last.popLast()!
                node[lastIndex].next = nodeIndex
            }
            // assertion: last.count == level
            last.append(nodeIndex)
        }
        if false { print(
            "DEBUG: ViewModel.evalCategoryTree(): node:\n" +
            node.enumerated().map {
                let name = data[$1.dataId]!.name
                return "  \($0): level=\($1.level), next=\($1.next), dataId=\($1.dataId) (\(name))\n"
            }.joined(separator: "") + "\n" +
            "DEBUG: ViewModel.evalCategoryTree(): index:\n" +
            index.keys.sorted(by: { $0.value < $1.value }).map {
                "  \($0.value) -> \(index[$0]!)\n"
            }.joined(separator: ""),
            separator: ""
        ) }
        return (node: node, index: index)
    }
}

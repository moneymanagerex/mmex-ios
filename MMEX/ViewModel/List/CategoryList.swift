//
//  CategoryList.swift
//  MMEX
//
//  2024-10-27: Created by George Ef (george.a.ef@gmail.com)
//

import SQLite

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

struct LoadCategoryPath: LoadEvalProtocol {
    typealias ValueType = (path: [DataId: String], order: [DataId])
    let loadName: String = "Path(\(CategoryRepository.repositoryName))"
    let idleValue: ValueType = (path: [:], order: [])

    var state: LoadState = .init()
    var value: ValueType

    init() {
        self.value = idleValue
    }

    nonisolated func evalValue(env: EnvironmentManager, vm: ViewModel) async -> ValueType? {
        await vm.evalCategoryPath()
    }
}

struct LoadCategoryTree: LoadEvalProtocol {
    // parent id (or -1) -> children ids (preserving order)
    typealias ValueType = (tree: [DataId: [DataId]], order: [(Int, DataId)])
    let loadName: String = "Tree(\(CategoryRepository.repositoryName))"
    let idleValue: ValueType = (tree: [:], order: [])
    var state: LoadState = .init()
    var value: ValueType

    init() {
        self.value = idleValue
    }

    nonisolated func evalValue(env: EnvironmentManager, vm: ViewModel) async -> ValueType? {
        await vm.evalCategoryTree()
    }
}

extension ViewModel {
    nonisolated func evalCategoryPath(sep: String = ":") async -> LoadCategoryPath.ValueType? {
        guard let data = await categoryList.data.readyValue else { return nil }

        var path: [DataId: String] = [:]
        for id in data.keys {
            var stack: [DataId] = []
            var id1 = id
            while id1 > 0, path[id1] == nil, let pid1 = data[id1]?.parentId {
                stack.append(id1)
                id1 = pid1
            }
            while let id1 = stack.popLast(), let name = data[id1]?.name {
                if let pid1 = data[id1]?.parentId, pid1 > 0, let path1 = path[pid1] {
                    path[id1] = path1 + sep + name
                } else {
                    path[id1] = name
                }
            }
        }

        let pathOrder = path
            .map { ($0.key, $0.value) }
            .sorted { ($0.1).localizedStandardCompare($1.1) == .orderedAscending }
            .map { $0.0 }

        return (path: path, order: pathOrder)
    }

    nonisolated func evalCategoryTree() async -> LoadCategoryTree.ValueType? {
        guard
            let data  = await categoryList.data.readyValue,
            let order = await categoryList.order.readyValue
        else { return nil }
        
        let tree = Dictionary(grouping: order) {
            { id in id > 0 ? id : -1 }(data[$0]?.parentId ?? -1)
        }

        var treeOrder: [(Int, DataId)] = []  // level, id
        var stack: [(Int, [DataId])] = [(0, tree[-1] ?? [])]  // index into list, list of items
        while !stack.isEmpty {
            let level = stack.endIndex - 1
            let (list_i, list) = stack[level]
            if list_i == list.count { _ = stack.popLast(); continue }
            let id = list[list_i]
            treeOrder.append((level, id))
            stack[level].0 += 1
            if let children = tree[id] { stack.append((0, children)) }
        }

        return (tree: tree, order: treeOrder)
    }
}
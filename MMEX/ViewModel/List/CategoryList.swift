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

    var path  : LoadCategoryPath              = .init()
    var order : LoadCategoryOrder             = .init()
}

struct LoadCategoryPath: LoadProtocol {
    typealias ValueType = [DataId: String]
    let loadName: String = "Path(\(CategoryRepository.repositoryName))"
    let idleValue: ValueType = [:]

    var state: LoadState = .init()
    var value: ValueType

    init() {
        self.value = idleValue
    }
}

struct LoadCategoryOrder: LoadProtocol {
    typealias ValueType = [DataId]
    let loadName: String = "Order(\(CategoryRepository.repositoryName))"
    let idleValue: ValueType = []

    var state: LoadState = .init()
    var value: ValueType

    init() {
        self.value = idleValue
    }
}

extension ViewModel {
    func evalCategoryPath(sep: String = ":") -> LoadCategoryPath.ValueType? {
        guard let data = categoryList.data.readyValue else { return nil }
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
        return path
    }

    func evalCategoryOrder() -> LoadCategoryOrder.ValueType? {
        guard let path = categoryList.path.readyValue else { return nil }
        return path.map { ($0.key, $0.value) }.sorted { $0.1 < $1.1 }.map { $0.0 }
    }
}

//
//  CategorySaerch.swift
//  MMEX
//
//  2024-11-17: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct CategorySearch: SearchProtocol {
    var area: [SearchArea<CategoryData>] = [
        ("Name", true,  {[ $0.name ]}, nil),
        ("Path", false, nil, { vm, data in [
            vm.categoryList.evalPath.readyValue?[data.id] ?? ""
        ] } ),
    ]
    var key: String = ""
}

extension ViewModel {
    func searchCategory(search: CategorySearch) {
        guard
            let listData = categoryList.data.readyValue,
            let evalTree = categoryList.evalTree.readyValue,
            categoryGroup.state == .ready
        else { return }

        if search.isEmpty {
            var i = 0
            while i < categoryGroup.value.count {
                let node = evalTree.order[i]
                if categoryGroup.value[i].memberInGroup == .boolFalse {
                    i = evalTree.order[i].next
                } else {
                    categoryGroup.value[i].isVisible = node.level == 0
                    categoryGroup.value[i].isExpanded = false
                    i += 1
                }
            }
            return
        }

        var i = 0
        while i < categoryGroup.value.count {
            let node = evalTree.order[i]
            let memberInGroup = categoryGroup.value[i].memberInGroup
            if memberInGroup == .boolFalse {
                i = evalTree.order[i].next
            } else {
                let memberInSearch: CategoryGroupMember =
                if memberInGroup != .boolTrue { .boolFalse } else {
                    search.match(self, listData[node.dataId]!) ? .boolTrue : .boolFalse
                }
                categoryGroup.value[i].memberInSearch = memberInSearch
                categoryGroup.value[i].isVisible = memberInSearch == .boolTrue
                categoryGroup.value[i].isExpanded = false
                i += 1
            }
        }
        for i in 0 ..< categoryGroup.value.count {
            guard categoryGroup.value[i].memberInSearch == .boolTrue else { continue }
            var p = evalTree.order[i].parent
            while p != -1, categoryGroup.value[p].memberInSearch == .boolFalse {
                categoryGroup.value[p].memberInSearch = .intermediate
                categoryGroup.value[p].isVisible = true
                categoryGroup.value[p].isExpanded = true
                p = evalTree.order[p].parent
            }
            if p != -1 {
                categoryGroup.value[p].isExpanded = true
            }
        }

        var stack: [(Int, Int)] = []  // index, current count
        i = 0
        while i < categoryGroup.value.count {
            let node = evalTree.order[i]
            while stack.count > node.level {
                let (p, count) = stack.popLast()!
                categoryGroup.value[p].countInSearch = count
                if !stack.isEmpty {
                    stack[stack.endIndex - 1].1 += count + 1
                }
            }
            // assertion: stack.count == node.level
            if categoryGroup.value[i].memberInSearch == .boolFalse {
                i = evalTree.order[i].next
            } else {
                stack.append((i, 0))
                i += 1
            }
        }
        while !stack.isEmpty {
            let (p, count) = stack.popLast()!
            categoryGroup.value[p].countInSearch = count
            if !stack.isEmpty {
                stack[stack.endIndex - 1].1 += count + 1
            }
        }

        if false { print(
            "DEBUG: ViewModel.searchCategory(\(search.key)): value:\n" +
            categoryGroup.value.enumerated().map { (i, groupNode) in
                let treeNode = evalTree.order[i]
                let (l, id) = (treeNode.level, treeNode.dataId)
                let mg = switch groupNode.memberInGroup {
                case .boolFalse: "N"; case .boolTrue: "Y"; case .intermediate: "int"
                }
                let ms = switch groupNode.memberInSearch {
                case .boolFalse: "N"; case .boolTrue: "Y"; case .intermediate: "int"
                }
                let m = mg == ms ? mg : "\(mg)->\(ms)"
                let cg = groupNode.countInGroup
                let cs = groupNode.countInSearch
                let c = cg == cs ? "\(cg)" : "\(cg)->\(cs)"
                let v = groupNode.isVisible  ? "V" : ""
                let e = groupNode.isExpanded ? "E" : ""
                let name = listData[id]!.name
                return "  \(i): l=\(l), m=\(m), c=\(c), ve=\(v)\(e), id=\(id) (\(name))\n"
            }.joined(separator: ""),
            terminator: ""
        ) }
    }
}

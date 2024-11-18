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
            categoryGroup.value.searchIsActive = false
            var i = 0
            while i < categoryGroup.value.order.count {
                let node = evalTree.order[i]
                if categoryGroup.value.order[i].memberInGroup == .boolFalse {
                    i = evalTree.order[i].next
                } else {
                    categoryGroup.value.order[i].isVisible = node.level == 0
                    categoryGroup.value.order[i].isExpanded = false
                    i += 1
                }
            }
            return
        }

        categoryGroup.value.searchIsActive = true
        var i = 0
        while i < categoryGroup.value.order.count {
            let node = evalTree.order[i]
            let memberInGroup = categoryGroup.value.order[i].memberInGroup
            if memberInGroup == .boolFalse {
                i = evalTree.order[i].next
            } else {
                let memberInSearch: CategoryGroupMember =
                if memberInGroup != .boolTrue { .boolFalse } else {
                    search.match(self, listData[node.dataId]!) ? .boolTrue : .boolFalse
                }
                categoryGroup.value.order[i].memberInSearch = memberInSearch
                categoryGroup.value.order[i].isVisible = memberInSearch == .boolTrue
                categoryGroup.value.order[i].isExpanded = false
                i += 1
            }
        }
        for i in 0 ..< categoryGroup.value.order.count {
            guard categoryGroup.value.order[i].memberInSearch == .boolTrue else { continue }
            var p = evalTree.order[i].parent
            while p != -1, categoryGroup.value.order[p].memberInSearch == .boolFalse {
                categoryGroup.value.order[p].memberInSearch = .intermediate
                categoryGroup.value.order[p].isVisible = true
                categoryGroup.value.order[p].isExpanded = true
                p = evalTree.order[p].parent
            }
            if p != -1 {
                categoryGroup.value.order[p].isExpanded = true
            }
        }

        var stack: [(Int, Int)] = []  // index, current count
        i = 0
        while i < categoryGroup.value.order.count {
            let node = evalTree.order[i]
            while stack.count > node.level {
                let (p, count) = stack.popLast()!
                categoryGroup.value.order[p].countInSearch = count
                if !stack.isEmpty {
                    stack[stack.endIndex - 1].1 += count + 1
                }
            }
            // assertion: stack.count == node.level
            if categoryGroup.value.order[i].memberInSearch == .boolFalse {
                i = evalTree.order[i].next
            } else {
                stack.append((i, 0))
                i += 1
            }
        }
        while !stack.isEmpty {
            let (p, count) = stack.popLast()!
            categoryGroup.value.order[p].countInSearch = count
            if !stack.isEmpty {
                stack[stack.endIndex - 1].1 += count + 1
            }
        }

        if false { print(
            "DEBUG: ViewModel.searchCategory(\(search.key)): order:\n" +
            categoryGroup.value.order.enumerated().map { (i, groupNode) in
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
    
    func expandCategory(_ i: Int) {
        guard
            let evalTree = categoryList.evalTree.readyValue,
            categoryGroup.state == .ready
        else { return }

        let next  = evalTree.order[i].next
        let isExpanded = categoryGroup.value.order[i].isExpanded

        var j = i + 1
        while j < next {
            if categoryGroup.value.member(j) == .boolFalse {
                j = evalTree.order[j].next
                continue
            }
            categoryGroup.value.order[j].isVisible = isExpanded
            if !categoryGroup.value.order[j].isExpanded {
                j = evalTree.order[j].next
            } else {
                j += 1
            }
        }
    }
}

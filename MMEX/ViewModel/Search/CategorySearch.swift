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
        if categoryGroup.search { return }
        guard
            let listData = categoryList.data.readyValue,
            let evalTree = categoryList.evalTree.readyValue,
            categoryGroup.state == .ready
        else { return }
        log.trace("DEBUG: ViewModel.searchCategory(\(search.key), main=\(Thread.isMainThread))")

        if search.isEmpty {
            categoryGroup.value.searchIsActive = false
            categoryGroupScanUnchecked { i in
                let isVisible = evalTree.order[i].level == 0
                self.categoryGroup.value.order[i].isVisible = isVisible
                self.categoryGroup.value.order[i].isExpanded = false
            }
        } else {
            categoryGroup.value.searchIsActive = true
            categoryGroupScanUnchecked { i in
                let id = evalTree.order[i].dataId
                let memberInGroup = self.categoryGroup.value.order[i].memberInGroup
                let memberInSearch: CategoryGroupMember =
                memberInGroup == .boolTrue && search.match(self, listData[id]!) ? .boolTrue : .boolFalse
                self.categoryGroup.value.order[i].memberInSearch = memberInSearch
                self.categoryGroup.value.order[i].isVisible      = memberInSearch == .boolTrue
                self.categoryGroup.value.order[i].isExpanded     = false
                guard memberInSearch == .boolTrue else { return }
                var p = evalTree.order[i].parent
                while p != -1, self.categoryGroup.value.order[p].memberInSearch == .boolFalse {
                    self.categoryGroup.value.order[p].memberInSearch = .intermediate
                    self.categoryGroup.value.order[p].isVisible      = true
                    self.categoryGroup.value.order[p].isExpanded     = true
                    p = evalTree.order[p].parent
                }
                if p != -1 {
                    self.categoryGroup.value.order[p].isExpanded = true
                }
            }
            
            var stack: [(Int, Int)] = []  // index, current count
            categoryGroupScanUnchecked { i in
                let level = evalTree.order[i].level
                while stack.count > level {
                    let (p, count) = stack.popLast()!
                    self.categoryGroup.value.order[p].countInSearch = count
                    if !stack.isEmpty {
                        stack[stack.endIndex - 1].1 += count + 1
                    }
                }
                // assertion: stack.count == node.level
                stack.append((i, 0))
            }
            while !stack.isEmpty {
                let (p, count) = stack.popLast()!
                categoryGroup.value.order[p].countInSearch = count
                if !stack.isEmpty {
                    stack[stack.endIndex - 1].1 += count + 1
                }
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
        
        categoryGroup.search = true
    }
    
    func expandCategory(_ i: Int) {
        guard
            let evalTree = categoryList.evalTree.readyValue,
            categoryGroup.state == .ready
        else { return }

        let next = evalTree.order[i].next
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

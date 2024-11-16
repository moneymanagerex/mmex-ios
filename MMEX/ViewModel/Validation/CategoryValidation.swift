//
//  CategoryValidation.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func copyCategory(_ data: inout CategoryData) {
        data.name.append(" (Copy)")
    }

    func updateCategory(_ data: inout CategoryData) -> String? {
        return "* not implemented"
    }

    func deleteCategory(_ data: CategoryData) -> String? {
        return "* not implemented"
    }
}

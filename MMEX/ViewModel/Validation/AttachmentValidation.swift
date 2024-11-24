//
//  AttachmentValidation.swift
//  MMEX
//
//  2024-11-05: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension AttachmentData {
    @MainActor
    mutating func update(_ vm: ViewModel) -> String? {
        if filename.isEmpty {
            return "Filename is empty"
        }

        // description may be empty
        // assumption: refType, refId are valid by construction

        typealias D = ViewModel.D
        guard let d = D(vm.db) else {
            return "* Database is not available"
        }

        if id.isVoid {
            guard d.insert(&self) else {
                return "* Cannot create new attachment"
            }
        } else {
            guard d.update(self) else {
                return "* Cannot update attachment #\(id.value)"
            }
        }

        return nil
    }

    @MainActor
    func delete(_ vm: ViewModel) -> String? {
        guard let attachmentUsed = vm.attachmentList.used.readyValue else {
            return "* attachmentUsed is not loaded"
        }
        if attachmentUsed.contains(id) {
            return "* Attachment #\(id.value) is used"
        }

        typealias D = ViewModel.D
        guard let d = D(vm.db) else {
            return "* Database is not available"
        }

        guard d.delete(self) else {
            return "* Cannot delete attachment #\(id.value)"
        }

        return nil
    }
}

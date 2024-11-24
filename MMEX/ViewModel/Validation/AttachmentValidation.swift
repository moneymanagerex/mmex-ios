//
//  AttachmentValidation.swift
//  MMEX
//
//  2024-11-05: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func updateAttachment(_ data: inout AttachmentData) -> String? {
        if data.filename.isEmpty {
            return "Filename is empty"
        }

        // data.description may be empty
        // assumption: data.refType, data.refId are valid by construction

        guard let d = D(self) else {
            return "* Database is not available"
        }

        if data.id.isVoid {
            guard d.insert(&data) else {
                return "* Cannot create new attachment"
            }
        } else {
            guard d.update(data) else {
                return "* Cannot update attachment #\(data.id.value)"
            }
        }

        return nil
    }

    func deleteAttachment(_ data: AttachmentData) -> String? {
        guard let attachmentUsed = attachmentList.used.readyValue else {
            return "* attachmentUsed is not loaded"
        }
        if attachmentUsed.contains(data.id) {
            return "* Attachment #\(data.id.value) is used"
        }

        guard let d = D(self) else {
            return "* Database is not available"
        }

        guard d.delete(data) else {
            return "* Cannot delete attachment #\(data.id.value)"
        }

        return nil
    }
}

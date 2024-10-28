//
//  PayeeValidation.swift
//  MMEX
//
//  2024-10-28: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite

extension ViewModel {
    func updatePayee(_ data: inout PayeeData) -> String? {
        return "* not implemented"
    }

    func deletePayee(_ data: PayeeData) -> String? {
        guard let payeeUsed = payeeList.used.readyValue else {
            return "* payeeUsed is not loaded"
        }
        if payeeUsed.contains(data.id) {
            return "* Payee #\(data.id) is used"
        }

        guard let p = P(env), let ax = AX(env) else {
            return "* Database is not available"
        }

        guard let payeeAtt = payeeList.att.readyValue else {
            return "* payeeAtt is not loaded"
        }
        if payeeAtt[data.id] != nil {
            guard ax.delete(refType: .payee, refId: data.id) else {
                return "* Cannot delete attachments for payee #\(data.id)"
            }
        }

        guard p.delete(data) else {
            return "* Cannot delete payee #\(data.id)"
        }

        return nil
    }
}

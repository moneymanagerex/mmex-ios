//
//  CheckingAccount.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import SQLite
import Foundation

enum Transcode: String, CaseIterable, Identifiable, Codable {
    case withdrawal = "Withdrawal"
    case deposit = "Deposit"
    case transfer = "Transfer"

    var id: String { self.rawValue }
    var name: String { rawValue.capitalized }
}

enum TransactionStatus: String, CaseIterable, Identifiable, Codable {
    case reconciled = "R" // Reconciled
    case void       = "V" // Void
    case followUp   = "F" // Follow up
    case duplicate  = "D" // Duplicate
    case none       = "N" // None
    
    var id: String { self.rawValue }
    var name: String { rawValue.capitalized }
    var fullName: String {
        return switch self {
        case .reconciled : "Reconciled"
        case .void       : "Void"
        case .followUp   : "Follow up"
        case .duplicate  : "Duplicate"
        case .none       : "None"
        }
    }
}

struct Transaction: ExportableEntity {
    var id: Int64
    var accountId: Int64
    var toAccountId: Int64?
    var payeeId: Int64
    var transCode: Transcode
    var transAmount: Double
    var status: TransactionStatus
    var transactionNumber: String?
    var notes: String?
    var categId: Int64?
    var transDate: String?
    var lastUpdatedTime: String?
    var deletedTime: String?
    var followUpId: Int64?
    var toTransAmount: Double?
    var color: Int64

    init(
        id: Int64, accountId: Int64, toAccountId: Int64? = nil, payeeId: Int64,
        transCode: Transcode, transAmount: Double, status: TransactionStatus,
        transactionNumber: String? = nil, notes: String? = nil, categId: Int64? = nil,
        transDate: String?, lastUpdatedTime: String? = nil, deletedTime: String? = nil,
        followUpId: Int64? = nil, toTransAmount: Double? = nil, color: Int64 = -1
    ) {
        self.id = id
        self.accountId = accountId
        self.toAccountId = toAccountId
        self.payeeId = payeeId
        self.transCode = transCode
        self.transAmount = transAmount
        self.status = status
        self.transactionNumber = transactionNumber
        self.notes = notes
        self.categId = categId
        self.transDate = transDate
        self.lastUpdatedTime = lastUpdatedTime
        self.deletedTime = deletedTime
        self.followUpId = followUpId
        self.toTransAmount = toTransAmount
        self.color = color
    }
}

extension Transaction {
    static var empty: Transaction { Transaction(
        id: 0, accountId: 0, payeeId: 0, transCode: Transcode.withdrawal,
        transAmount: 0.0, status: TransactionStatus.none, categId: 0,
        transDate: Date().ISO8601Format()
    ) }
}

extension Transaction: ModelProtocol {
    static let modelName = "Transaction"

    func shortDesc() -> String {
        "\(self.id)"
    }
}

extension Transaction {
    var day: String {
        // Extract the date portion (ignoring the time) from ISO-8601 string
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // ISO-8601 format
 
        if let date = formatter.date(from: transDate ?? "") {
            formatter.dateFormat = "yyyy-MM-dd" // Extract just the date
            return formatter.string(from: date)
        }
        return transDate ?? "" // If parsing fails, return original string
    }
}

extension Transaction {
    static let sampleData : [Transaction] = [
        Transaction(
            id: 1, accountId: 1, payeeId: 1, transCode: Transcode.withdrawal,
            transAmount: 10.01, status: TransactionStatus.none, categId: 1,
            transDate: Date().ISO8601Format()
        ),
        Transaction(
            id: 2, accountId: 2, payeeId: 2, transCode: Transcode.deposit,
            transAmount: 20.02, status: TransactionStatus.none, categId: 1,
            transDate: Date().ISO8601Format()
        ),
        Transaction(
            id: 3, accountId: 3, payeeId: 3, transCode: Transcode.transfer,
            transAmount: 30.03, status: TransactionStatus.none, categId: 1,
            transDate: Date().ISO8601Format()
        ),
    ]
}

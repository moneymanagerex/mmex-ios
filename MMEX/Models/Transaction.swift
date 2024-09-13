//
//  CheckingAccount.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import SQLite
import Foundation

enum Transcode: String, CaseIterable, Identifiable {
    case withdrawal = "Withdrawal"
    case deposit = "Deposit"
    case transfer = "Transfer"

    var id: String { self.rawValue }
    var name: String {
        rawValue.capitalized
    }
}

enum TransactionStatus: String, CaseIterable, Identifiable {
    case reconciled = "R" // Reconciled
    case void = "V" // Void
    case followUp = "F" // "Follow up"
    case duplicate = "D" // "Duplicate"
    case none = "N"// "None"
    
    var id: String {self.rawValue}
    var name: String {
        rawValue.capitalized
    }
}

struct Transaction: Identifiable {
    var id: Int64 // TRANSID
    var accountID: Int64
    var toAccountID: Int64?
    var payeeID: Int64
    var transcode: Transcode
    var transAmount: Double?
    var status: TransactionStatus
    var transactionNumber: String?
    var notes: String?
    var categID: Int64?
    var transDate: String
    var lastUpdatedTime: String?
    var deletedTime: String?
    var followUpID: Int64?
    var toTransAmount: Double?
    var color: Int64?
    
    init(id: Int64, accountID: Int64, toAccountID: Int64? = nil, payeeID: Int64, transCode: Transcode, transAmount: Double?, status: TransactionStatus, transactionNumber: String? = nil, notes: String? = nil, categID: Int64? = nil, transDate: String, lastUpdatedTime: String? = nil, deletedTime: String? = nil, followUpID: Int64? = nil, toTransAmount: Double? = nil, color: Int64? = nil) {
        self.id = id
        self.accountID = accountID
        self.toAccountID = toAccountID
        self.payeeID = payeeID
        self.transcode = transCode
        self.transAmount = transAmount
        self.status = status
        self.transactionNumber = transactionNumber
        self.notes = notes
        self.categID = categID
        self.transDate = transDate
        self.lastUpdatedTime = lastUpdatedTime
        self.deletedTime = deletedTime
        self.followUpID = followUpID
        self.toTransAmount = toTransAmount
        self.color = color
    }
    
    init(id: Int64, accountID: Int64, payeeID: Int64, categID: Int64?, transCode: Transcode, status:TransactionStatus, transAmount: Double?, transDate: String) {
        self.id = id
        self.accountID = accountID
        self.payeeID = payeeID
        self.categID = categID
        self.transcode = transCode
        self.status = status
        self.transAmount = transAmount
        self.transDate = transDate
    }
}

extension Transaction {
    var day: String {
        // Extract the date portion (ignoring the time) from ISO-8601 string
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // ISO-8601 format
 
        if let date = formatter.date(from: transDate) {
            formatter.dateFormat = "yyyy-MM-dd" // Extract just the date
            return formatter.string(from: date)
        }
        return transDate // If parsing fails, return original string
    }
}

extension Transaction {
    static var empty: Transaction {Transaction(id: 0, accountID: 1, payeeID: 1, categID:1, transCode: Transcode.withdrawal, status: TransactionStatus.none, transAmount: 0.0, transDate: Date().ISO8601Format())}
    static let sampleData : [Transaction] =
    [
        Transaction(id: 1, accountID: 1, payeeID: 1, categID:1, transCode: Transcode.withdrawal, status: TransactionStatus.none, transAmount: 0.0, transDate: Date().ISO8601Format()),
        Transaction(id: 2, accountID: 2, payeeID: 2, categID:1, transCode: Transcode.deposit, status: TransactionStatus.none,transAmount: 0.0, transDate: Date().ISO8601Format()),
        Transaction(id: 3, accountID: 3, payeeID: 3, categID:1, transCode: Transcode.transfer, status: TransactionStatus.none, transAmount: 0.0, transDate: Date().ISO8601Format())
    ]
}

extension Transaction
{
    // SQLite columns
    static let table = Table("CHECKINGACCOUNT_V1")
    static let transID = Expression<Int64>("TRANSID")
    static let accountIDExpr = Expression<Int64>("ACCOUNTID")
    static let toAccountIDExpr = Expression<Int64?>("TOACCOUNTID")
    static let payeeIDExpr = Expression<Int64>("PAYEEID")
    static let transCodeExpr = Expression<String>("TRANSCODE")
    static let transAmountExpr = Expression<Double?>("TRANSAMOUNT")
    static let statusExpr = Expression<String?>("STATUS")
    static let transactionNumberExpr = Expression<String?>("TRANSACTIONNUMBER")
    static let notesExpr = Expression<String?>("NOTES")
    static let categIDExpr = Expression<Int64?>("CATEGID")
    static let transDateExpr = Expression<String>("TRANSDATE")
    static let lastUpdatedTimeExpr = Expression<String?>("LASTUPDATEDTIME")
    static let deletedTimeExpr = Expression<String?>("DELETEDTIME")
    static let followUpIDExpr = Expression<Int64?>("FOLLOWUPID")
    static let toTransAmountExpr = Expression<Double?>("TOTRANSAMOUNT")
    static let colorExpr = Expression<Int64?>("COLOR")
}

//
//  Transaction.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import SQLite
import Foundation

enum Transcode: String, EnumCollateNoCase {
    case withdrawal = "Withdrawal"
    case deposit    = "Deposit"
    case transfer   = "Transfer"
}

enum TransactionStatus: String, CaseIterable, Identifiable, Codable {
    // TODO: MMEX Desktop defines "" for none
    case none       = "N" // None
    case reconciled = "R" // Reconciled
    case void       = "V" // Void
    case followUp   = "F" // Follow up
    case duplicate  = "D" // Duplicate
    
    var id: String { self.rawValue }
    var name: String { rawValue.capitalized }
    var fullName: String {
        return switch self {
        // TODO: MMEX Desktop defines "Unreconciled" for none
        case .none       : "None"
        case .reconciled : "Reconciled"
        case .void       : "Void"
        case .followUp   : "Follow up"
        case .duplicate  : "Duplicate"
        }
    }
}

struct TransactionData: ExportableEntity {
    var id                : Int64
    var accountId         : Int64
    var toAccountId       : Int64
    var payeeId           : Int64
    var transCode         : Transcode
    var transAmount       : Double
    var status            : TransactionStatus
    var transactionNumber : String
    var notes             : String
    var categId           : Int64
    var transDate         : String
    var lastUpdatedTime   : String
    var deletedTime       : String
    var followUpId        : Int64
    var toTransAmount     : Double
    var color             : Int64

    init(
        id                : Int64             = 0,
        accountId         : Int64             = 0,
        toAccountId       : Int64             = 0,
        payeeId           : Int64             = 0,
        transCode         : Transcode         = Transcode.withdrawal,
        transAmount       : Double            = 0.0,
        status            : TransactionStatus = TransactionStatus.none,
        transactionNumber : String            = "",
        notes             : String            = "",
        categId           : Int64             = 0,
        transDate         : String            = "",
        lastUpdatedTime   : String            = "",
        deletedTime       : String            = "",
        followUpId        : Int64             = 0,
        toTransAmount     : Double            = 0.0,
        color             : Int64             = 0
    ) {
        self.id                = id
        self.accountId         = accountId
        self.toAccountId       = toAccountId
        self.payeeId           = payeeId
        self.transCode         = transCode
        self.transAmount       = transAmount
        self.status            = status
        self.transactionNumber = transactionNumber
        self.notes             = notes
        self.categId           = categId
        self.transDate         = transDate
        self.lastUpdatedTime   = lastUpdatedTime
        self.deletedTime       = deletedTime
        self.followUpId        = followUpId
        self.toTransAmount     = toTransAmount
        self.color             = color
    }
}

extension TransactionData: DataProtocol {
    static let modelName = "Transaction"

    func shortDesc() -> String {
        "\(self.id)"
    }
}

struct TransactionFull: FullProtocol {
    var data: TransactionData
    var accountName       : String?
    var accountCurrency   : CurrencyData?
    var toAccountName     : String?
    var toAccountCurrency : String?
    var assets            : [AssetData] = []
    var stocks            : [StockData] = []
    var categoryName      : String?
    var payeeName         : String?
  //var tags              : [TagData]
  //var fields            : [(FieldData, String?)]
}

extension TransactionData {
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

extension TransactionData {
    static let sampleData : [TransactionData] = [
        TransactionData(
            id: 1, accountId: 1, payeeId: 1, transCode: Transcode.withdrawal,
            transAmount: 10.01, status: TransactionStatus.none, categId: 1,
            transDate: Date().ISO8601Format()
        ),
        TransactionData(
            id: 2, accountId: 2, payeeId: 2, transCode: Transcode.deposit,
            transAmount: 20.02, status: TransactionStatus.none, categId: 1,
            transDate: Date().ISO8601Format()
        ),
        TransactionData(
            id: 3, accountId: 3, payeeId: 3, transCode: Transcode.transfer,
            transAmount: 30.03, status: TransactionStatus.none, categId: 1,
            transDate: Date().ISO8601Format()
        ),
    ]
}

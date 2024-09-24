//
//  Transaction.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/9.
//

import SQLite
import Foundation

enum TransactionType: String, EnumCollateNoCase {
    case withdrawal = "Withdrawal"
    case deposit    = "Deposit"
    case transfer   = "Transfer"
    static let defaultValue = Self.withdrawal
}

enum TransactionStatus: String, EnumCollateNoCase {
    // TODO: MMEX Desktop defines "" for none
    case none       = "N" // None
    case reconciled = "R" // Reconciled
    case void       = "V" // Void
    case followUp   = "F" // Follow up
    case duplicate  = "D" // Duplicate
    static let defaultValue = Self.none

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

    init(collateNoCase name: String?) {
        guard let name else { self = Self.defaultValue; return }
        for x in Self.allCases {
            if x.rawValue.caseInsensitiveCompare(name) == .orderedSame ||
                x.fullName.caseInsensitiveCompare(name) == .orderedSame
            {
                self = x
                return
            }
        }
        self = Self.defaultValue
    }
}

struct TransactionData: ExportableEntity {
    var id                : Int64             = 0
    var accountId         : Int64             = 0
    var toAccountId       : Int64             = 0
    var payeeId           : Int64             = 0
    var transCode         : TransactionType   = TransactionType.defaultValue
    var transAmount       : Double            = 0.0
    var status            : TransactionStatus = TransactionStatus.defaultValue
    var transactionNumber : String            = ""
    var notes             : String            = ""
    var categId           : Int64             = 0
    var transDate         : String            = ""
    var lastUpdatedTime   : String            = ""
    var deletedTime       : String            = ""
    var followUpId        : Int64             = 0
    var toTransAmount     : Double            = 0.0
    var color             : Int64             = 0
}

extension TransactionData: DataProtocol {
    static let dataName = "Transaction"

    func shortDesc() -> String {
        "\(self.id)"
    }
}

/* TODO: move to ViewModels
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
*/

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
            id: 1, accountId: 1, payeeId: 1, transCode: TransactionType.withdrawal,
            transAmount: 10.01, status: TransactionStatus.none, categId: 1,
            transDate: Date().ISO8601Format()
        ),
        TransactionData(
            id: 2, accountId: 2, payeeId: 2, transCode: TransactionType.deposit,
            transAmount: 20.02, status: TransactionStatus.none, categId: 1,
            transDate: Date().ISO8601Format()
        ),
        TransactionData(
            id: 3, accountId: 3, payeeId: 3, transCode: TransactionType.transfer,
            transAmount: 30.03, status: TransactionStatus.none, categId: 1,
            transDate: Date().ISO8601Format()
        ),
    ]
}

//
//  ViewModel.swift
//  MMEX
//
//  2024-10-19: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI
import SQLite
import Combine

@MainActor
class ViewModel: ObservableObject {
    // for file database: db != nil && databaseURL != nil
    // for in-memmory database: db != nil && databaseURL == nil
    @Published var isDatabaseConnected = false
    var db: Connection?
    var databaseURL: URL?

    @Published var journalList  : LoadState = .init()
    @Published var insightsList : LoadState = .init()
    @Published var enterList    : LoadState = .init()
    @Published var manageList   : LoadState = .init()
    @Published var settingsList : LoadState = .init()

    typealias I = InfotableRepository
    @Published var infotableList : InfotableList  = .init()

    typealias U = CurrencyRepository
    typealias UH = CurrencyHistoryRepository
    @Published var currencyList  : CurrencyList  = .init()
    @Published var currencyGroup : CurrencyGroup = .init()

    typealias A = AccountRepository
    @Published var accountList  : AccountList  = .init()
    @Published var accountGroup : AccountGroup = .init()

    typealias E = AssetRepository
    @Published var assetList  : AssetList  = .init()
    @Published var assetGroup : AssetGroup = .init()

    typealias S = StockRepository
    typealias SH = StockHistoryRepository
    @Published var stockList  : StockList  = .init()
    @Published var stockGroup : StockGroup = .init()

    typealias C = CategoryRepository
    @Published var categoryList  : CategoryList  = .init()
    @Published var categoryGroup : CategoryGroup = .init()

    typealias P = PayeeRepository
    @Published var payeeList  : PayeeList  = .init()
    @Published var payeeGroup : PayeeGroup = .init()

    typealias T = TransactionRepository
    typealias TP = TransactionSplitRepository
    typealias TL = TransactionLinkRepository
    typealias TS = TransactionShareRepository
    static let T_table: SQLite.Table = T.table.filter(T.col_deletedTime == "")
    @Published var transactionList  : TransactionList  = .init()
    //@Published var transactionGroup : TransactionGroup = .init()

    typealias Q = ScheduledRepository
    typealias QP = ScheduledSplitRepository
    @Published var scheduledList  : ScheduledList  = .init()
    //@Published var scheduledGroup : ScheduledGroup = .init()

    typealias G = TagRepository
    typealias GL = TagLinkRepository
    @Published var tagList  : TagList  = .init()
    @Published var tagGroup : TagGroup = .init()

    typealias F = FieldRepository
    typealias FV = FieldValueRepository
    @Published var fieldList  : FieldList  = .init()
    @Published var fieldGroup : FieldGroup = .init()

    typealias D = AttachmentRepository
    @Published var attachmentList  : AttachmentList  = .init()
    @Published var attachmentGroup : AttachmentGroup = .init()

    typealias BP = BudgetPeriodRepository
    @Published var budgetPeriodList  : BudgetPeriodList  = .init()
    @Published var budgetPeriodGroup : BudgetPeriodGroup = .init()

    typealias B = BudgetRepository
    @Published var budgetList  : BudgetList  = .init()
    @Published var budgetGroup : BudgetGroup = .init()

    typealias R = ReportRepository
    @Published var reportList  : ReportList  = .init()
    @Published var reportGroup : ReportGroup = .init()

    // moved from TransactionViewModel.swift
    @Published var txns: [TransactionData] = []
    @Published var txns_per_day: [String: [TransactionData]] = [:]

    // moved from InsightsViewModel
    @Published var baseCurrency: CurrencyData?
    @Published var stats: [TransactionData] = [] // all transactions
    @Published var recentStats: [TransactionData] = []
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var flow = InsightsFlow()
    var cancellables = Set<AnyCancellable>()

    init() {
    }

    init(withStoredDatabase: Void) {
        connectToStoredDatabase()
    }

    init(withSampleDatabaseInMemory: Void) {
        createDatabase(at: nil, sampleData: true)
    }
}

extension ViewModel {
    func name<DataType: DataProtocol>(_ data: DataType) -> String {
        if let data = data as? InfotableData {
            return data.name
        } else if let data = data as? CurrencyData {
            return data.name
        } else if let data = data as? AccountData {
            return data.name
        } else if let data = data as? AssetData {
            return data.name
        } else if let data = data as? StockData {
            return data.name
        } else if let data = data as? CategoryData {
            // TODO: name -> path
            return data.name
        } else if let data = data as? PayeeData {
            return data.name
        } else if let data = data as? TransactionData {
            return data.shortDesc()
        } else if let data = data as? ScheduledData {
            return data.shortDesc()
        } else if let data = data as? TagData {
            return data.name
        } else if let data = data as? FieldData {
            return data.shortDesc()
        } else if let data = data as? AttachmentData {
            return data.shortDesc()
        } else if let data = data as? BudgetPeriodData {
            return data.name
        } else if let data = data as? BudgetData {
            return data.shortDesc()
        } else if let data = data as? ReportData {
            return data.name
        }
        return ""
    }

    func filename<DataType: DataProtocol>(_ data: DataType) -> String {
        return "\(name(data))_\(DataType.dataName.0)"
    }
}

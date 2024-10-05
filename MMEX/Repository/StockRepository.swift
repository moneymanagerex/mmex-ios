//
//  StockRepository.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SQLite

struct StockRepository: RepositoryProtocol {
    typealias RepositoryData = StockData

    let db: Connection
    init(_ db: Connection) {
        self.db = db
    }
    init?(_ db: Connection?) {
        guard let db else { return nil }
        self.db = db
    }

    static let repositoryName = "STOCK_V1"
    static let table = SQLite.Table(repositoryName)

    // column        | type    | other
    // --------------+---------+------
    // STOCKID       | INTEGER | PRIMARY KEY
    // HELDAT        | INTEGER |
    // STOCKNAME     | TEXT    | NOT NULL COLLATE NOCASE
    // SYMBOL        | TEXT    |
    // NUMSHARES     | NUMERIC |
    // PURCHASEDATE  | TEXT    | NOT NULL
    // PURCHASEPRICE | NUMERIC | NOT NULL
    // CURRENTPRICE  | NUMERIC | NOT NULL
    // VALUE         | NUMERIC |
    // COMMISSION    | NUMERIC |
    // NOTES         | TEXT    |

    // column expressions
    static let col_id            = SQLite.Expression<Int64>("STOCKID")
    static let col_accountId     = SQLite.Expression<Int64?>("HELDAT")
    static let col_name          = SQLite.Expression<String>("STOCKNAME")
    static let col_symbol        = SQLite.Expression<String?>("SYMBOL")
    static let col_numShares     = SQLite.Expression<Double?>("NUMSHARES")
    static let col_purchaseDate  = SQLite.Expression<String>("PURCHASEDATE")
    static let col_purchasePrice = SQLite.Expression<Double>("PURCHASEPRICE")
    static let col_currentPrice  = SQLite.Expression<Double>("CURRENTPRICE")
    static let col_value         = SQLite.Expression<Double?>("VALUE")
    static let col_commisison    = SQLite.Expression<Double?>("COMMISSION")
    static let col_notes         = SQLite.Expression<String?>("NOTES")

    // cast NUMERIC to REAL
    static let cast_numShares     = cast(col_numShares)     as SQLite.Expression<Double?>
    static let cast_purchasePrice = cast(col_purchasePrice) as SQLite.Expression<Double>
    static let cast_currentPrice  = cast(col_currentPrice)  as SQLite.Expression<Double>
    static let cast_value         = cast(col_value)         as SQLite.Expression<Double?>
    static let cast_commisison    = cast(col_commisison)    as SQLite.Expression<Double?>

    static func selectData(from table: SQLite.Table) -> SQLite.Table {
        return table.select(
            col_id,
            col_accountId,
            col_name,
            col_symbol,
            cast_numShares,
            col_purchaseDate,
            cast_purchasePrice,
            cast_currentPrice,
            cast_value,
            cast_commisison,
            col_notes
        )
    }

    static func fetchData(_ row: SQLite.Row) -> StockData {
        return StockData(
            id            : row[col_id],
            accountId     : row[col_accountId] ?? 0,
            name          : row[col_name],
            symbol        : row[col_symbol] ?? "",
            numShares     : row[cast_numShares] ?? 0.0,
            purchaseDate  : DateString(row[col_purchaseDate]),
            purchasePrice : row[cast_purchasePrice],
            currentPrice  : row[cast_currentPrice],
            value         : row[cast_value] ?? 0.0,
            commisison    : row[cast_commisison] ?? 0.0,
            notes         : row[col_notes] ?? ""
        )
    }

    static func itemSetters(_ data: StockData) -> [SQLite.Setter] {
        return [
            col_accountId     <- data.accountId,
            col_name          <- data.name,
            col_symbol        <- data.symbol,
            col_numShares     <- data.numShares,
            col_purchaseDate  <- data.purchaseDate.string,
            col_purchasePrice <- data.purchasePrice,
            col_currentPrice  <- data.currentPrice,
            col_value         <- data.value,
            col_commisison    <- data.commisison,
            col_notes         <- data.notes
        ]
    }
}

extension StockRepository {
    // load all stocks
    func load() -> [StockData] {
        return select(from: Self.table
            .order(Self.col_name)
        )
    }
    
    // load stock by account
    func loadByAccount<Result>(
        from table: SQLite.Table = Self.table,
        with result: (SQLite.Row) -> Result = Self.fetchData
    ) -> [Int64: [Result]] {
        do {
            var dataByAccount: [Int64: [Result]] = [:]
            for row in try db.prepare(Self.selectData(from: table)) {
                let accountId = row[Self.col_accountId] ?? 0
                if dataByAccount[accountId] == nil { dataByAccount[accountId] = [] }
                dataByAccount[accountId]!.append(result(row))
            }
            log.info("Successfull select from \(Self.repositoryName): \(dataByAccount.count)")
            return dataByAccount
        } catch {
            log.error("Failed select from \(Self.repositoryName): \(error)")
            return [:]
        }
    }

}

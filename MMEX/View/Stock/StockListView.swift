//
//  StockListView.swift
//  MMEX
//
//  Created 2024-10-03 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct StockListView: View {
    @EnvironmentObject var env: EnvironmentManager

    @State private var allAccountName: [(Int64, String)] = [] // sorted by name
    @State private var allStockDataByAccount: [Int64: [StockData]] = [:] // sorted by name
    @State private var isTypeVisible:  [Int64: Bool] = [:]
    @State private var isTypeExpanded: [Int64: Bool] = [:]
    @State private var search: String = ""
    @State private var isPresentingAddView = false
    @State private var newStock = emptyStock

    static let emptyStock = StockData(
    )

    var body: some View {
        NavigationStack {
            List {
                let accountIds = Array(allStockDataByAccount.keys)
                ForEach(accountIds, id: \.self) { accountId in
                    if isTypeVisible[accountId] == true {
                        Section(
                            header: HStack {
                                Button(action: {
                                    isTypeExpanded[accountId]?.toggle()
                                }) {
                                    env.theme.group.hstack(
                                        isTypeExpanded[accountId] == true
                                    ) {
                                        Text(env.accountCache[accountId]?.name ?? "(No Account)")
                                    }
                                }
                            }
                        ) {
                            // Show stock list based on expanded state
                            if isTypeExpanded[accountId] == true,
                               let stocks = allStockDataByAccount[accountId]
                            {
                                ForEach(stocks) { stock in
                                    // TODO: update View after change in stock
                                    if search.isEmpty || match(stock, search) {
                                        itemView(stock)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .toolbar {
                Button(
                    action: { isPresentingAddView = true },
                    label: { Image(systemName: "plus") }
                )
                .accessibilityLabel("New Stock")
            }
            .searchable(text: $search, prompt: "Search by name")
            .textInputAutocapitalization(.never)
            .onChange(of: search) { _, value in
                filterType(by: value)
            }
        }
        .navigationTitle("Stocks")
        .onAppear {
            loadAccountName()
            loadStockData()
        }
        .sheet(isPresented: $isPresentingAddView) {
            StockAddView(
                allAccountName: $allAccountName,
                newStock: $newStock,
                isPresentingAddView: $isPresentingAddView
            ) { newStock in
                addStock(stock: &newStock)
                newStock = Self.emptyStock
            }
        }
    }

    func itemView(_ stock: StockData) -> some View {
        NavigationLink(destination: StockDetailView(
            allAccountName: $allAccountName,
            stock: stock
        ) ) {
            HStack {
                Text(stock.name)
                    .font(.subheadline)
                
                Spacer()

                if let account = env.accountCache[stock.accountId],
                   let formatter = env.currencyCache[account.currencyId]?.formatter
                {
                    Text(stock.value.formatted(by: formatter))
                        .font(.subheadline)
                }
           }
            .padding(.horizontal)
        }
    }

    // Initialize the expanded state for each account
    private func initializeAccount() {
        for accountId in allStockDataByAccount.keys {
            isTypeVisible[accountId] = true
            isTypeExpanded[accountId] = true // Default to expanded
        }
    }

    func filterType(by search: String) {
        for accountId in allStockDataByAccount.keys {
            let matched = search.isEmpty || allStockDataByAccount[accountId]?.first(where: { match($0, search) }) != nil
            isTypeVisible[accountId] = matched
            if matched { isTypeExpanded[accountId] = true }
        }
    }

    func match(_ stock: StockData, _ search: String) -> Bool {
        stock.name.localizedCaseInsensitiveContains(search)
    }

    func loadAccountName() {
        let repo = env.accountRepository
        DispatchQueue.global(qos: .background).async {
            let id_name = repo?.loadName() ?? []
            DispatchQueue.main.async {
                self.allAccountName = id_name
            }
        }
    }

    func loadStockData() {
        let repository = env.stockRepository
        DispatchQueue.global(qos: .background).async {
            typealias S = StockRepository
            let dataByAccount = repository?.loadByAccount(
                from: S.table.order(S.col_name)
            ) ?? [:]
            DispatchQueue.main.async {
                self.allStockDataByAccount = dataByAccount
                self.initializeAccount()
            }
        }
    }

    func addStock(stock: inout StockData) {
        guard let repository = env.stockRepository else { return }
        if repository.insert(&stock) {
            self.loadStockData()
        }
    }
}

#Preview {
    StockListView(
    )
    .environmentObject(EnvironmentManager.sampleData)
}

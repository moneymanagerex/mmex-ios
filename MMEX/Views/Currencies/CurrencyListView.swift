//
//  CurrencyListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/17.
//

import SwiftUI

struct CurrencyListView: View {
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment

    @State private var allCurrencyData: [CurrencyData] = [] // sorted by name
    @State private var newCurrency = emptyCurrency
    @State private var isPresentingCurrencyAddView = false
    @State private var expandedSections: [Bool : Bool] = [true: true, false: false]

    static let emptyCurrency = CurrencyData(
        decimalPoint   : ".",
        groupSeparator : ",",
        scale          : 100,
        baseConvRate   : 1.0
    )

    var body: some View {
        NavigationStack {
            List {
                ForEach([true, false], id: \.self) { inUse in
                    Section(header: HStack {
                        Button(action: {
                            expandedSections[inUse]?.toggle()
                        }) {
                            Text(inUse ? "In-Use" : "Not-In-Use")
                                .font(.subheadline)
                                .padding(.leading)
                            Spacer()
                            // Expand or collapse indicator
                            Image(systemName: expandedSections[inUse] == true ? "chevron.down" : "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }) {
                        if expandedSections[inUse] == true {
                            ForEach(allCurrencyData) { currency in
                                if (dataManager.currencyCache[currency.id] != nil) == inUse {
                                    itemView(currency)
                                }
                            }
                        }
                    }
                }
            }
            .toolbar {
                Button(action: {
                    isPresentingCurrencyAddView = true
                }, label: {
                    Image(systemName: "plus")
                })
            }
        }
        .navigationTitle("Currencies")
        .onAppear {
            loadCurrencyData()
        }
        .sheet(isPresented: $isPresentingCurrencyAddView) {
            CurrencyAddView(
                newCurrency: $newCurrency,
                isPresentingCurrencyAddView: $isPresentingCurrencyAddView
            ) { currency in
                addCurrency(&currency)
                newCurrency = Self.emptyCurrency
            }
        }
    }

    func itemView(_ currency: CurrencyData) -> some View {
        NavigationLink(destination: CurrencyDetailView(
            currency: currency
        ) ) { HStack {
            Text(currency.name)
            Spacer()
            Text(currency.symbol)
        } }
    }

    func loadCurrencyData() {
        let repository = dataManager.currencyRepository
        DispatchQueue.global(qos: .background).async {
            let data = repository?.load() ?? []
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.allCurrencyData = data
            }
        }
    }

    func addCurrency(_ currency: inout CurrencyData) {
        guard let repository = dataManager.currencyRepository else { return }
        if repository.insert(&currency) {
            self.loadCurrencyData()
        } else {
            // TODO
        }
    }
}

#Preview {
    CurrencyListView(
    )
    .environmentObject(DataManager.sampleDataManager)
}

#Preview {
    NavigationStack { List { Section("Currency") {
        CurrencyListView().itemView(CurrencyData.sampleData[0])
    } } }
}

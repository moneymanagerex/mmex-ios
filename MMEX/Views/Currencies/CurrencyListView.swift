//
//  CurrencyListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/17.
//

import SwiftUI

struct CurrencyListView: View {
    @EnvironmentObject var dataManager: DataManager // Access DataManager from environment
    @State private var currencyData: [CurrencyData] = []
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
                Section(header: HStack {
                    Button(action: {
                        expandedSections[true]?.toggle()
                    }) {
                        Text("In-Use")
                            .font(.subheadline)
                            .padding(.leading)
                        Spacer()
                        // Expand or collapse indicator
                        Image(systemName: expandedSections[true] == true ? "chevron.down" : "chevron.right")
                            .foregroundColor(.gray)
                    }
                }) {
                    ForEach(currencyData) { currency in
                        if dataManager.currencyData[currency.id] != nil {
                            NavigationLink(destination: CurrencyDetailView(currency: currency)) {
                                HStack {
                                    Text(currency.name)
                                    Spacer()
                                    Text(currency.symbol)
                                }
                            }
                        }
                    }
                }
                
                Section(header: HStack {
                    Button(action: {
                        expandedSections[false]?.toggle()
                    }) {
                        Text("Not-In-Use")
                            .font(.subheadline)
                            .padding(.leading)
                        Spacer()
                        // Expand or collapse indicator
                        Image(systemName: expandedSections[false] == true ? "chevron.down" : "chevron.right")
                            .foregroundColor(.gray)
                    }
                }) {
                    // Show account list based on expandedSections state
                    if expandedSections[false] == true {
                        ForEach(currencyData) { currency in
                            if dataManager.currencyData[currency.id] == nil {
                                NavigationLink(destination: CurrencyDetailView(currency: currency)) {
                                    HStack {
                                        Text(currency.name)
                                        Spacer()
                                        Text(currency.symbol)
                                    }
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
            loadCurrencies()
        }
        .sheet(isPresented: $isPresentingCurrencyAddView) {
            CurrencyAddView(newCurrency: $newCurrency, isPresentingCurrencyAddView: $isPresentingCurrencyAddView) { currency in
                addCurrency(&currency)
                newCurrency = Self.emptyCurrency
            }
        }
    }
    
    func loadCurrencies() {
        let repository = dataManager.currencyRepository
        DispatchQueue.global(qos: .background).async {
            let data = repository?.load() ?? []
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.currencyData = data
            }
        }
    }

    func addCurrency(_ currency: inout CurrencyData) {
        guard let repository = dataManager.currencyRepository else { return }
        if repository.insert(&currency) {
            self.loadCurrencies()
        } else {
            // TODO
        }
    }
}

#Preview {
    CurrencyListView()
        .environmentObject(DataManager())
}

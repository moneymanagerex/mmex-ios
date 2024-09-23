//
//  CurrencyListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/17.
//

import SwiftUI

struct CurrencyListView: View {
    let databaseURL: URL
    @State private var currencies: [Bool: [CurrencyData]] = [:]
    @State private var newCurrency = CurrencyData()
    @State private var isPresentingCurrencyAddView = false
    @State private var expandedSections: [Bool : Bool] = [true: true, false: false]
    
    private var repository: CurrencyRepository
    
    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.repository = DataManager(databaseURL: databaseURL).getCurrencyRepository()
    }
    
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
                    if let inUseCurrencies = currencies[true] {
                        ForEach(inUseCurrencies) { currency in
                            NavigationLink(destination: CurrencyDetailView(currency: currency, databaseURL: databaseURL)) {
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
                        if let notInUseCurrencies = currencies[false] {
                            ForEach(notInUseCurrencies) { currency in
                                NavigationLink(destination: CurrencyDetailView(currency: currency, databaseURL: databaseURL)) {
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
                newCurrency = CurrencyData()
            }
        }
    }
    
    func loadCurrencies() {
        // Fetch accounts using repository and update the view
        DispatchQueue.global(qos: .background).async {
            let loadedCurrencies = repository.load()
            let loadedAccounts = DataManager(databaseURL: databaseURL).getAccountRepository().load()

            // Get a set of all currency IDs used by accounts
            let usedCurrencyIds = Set(loadedAccounts.map { $0.currencyId })
            
            // Categorize currencies into in-use (true) and not-in-use (false)
            let categorized = Dictionary(grouping: loadedCurrencies, by: { usedCurrencyIds.contains($0.id) })
            
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.currencies = categorized
            }
        }
    }

    func addCurrency(_ currency: inout CurrencyData) {
        if repository.insert(&currency) {
            self.loadCurrencies()
        } else {
            // TODO
        }
    }
}

#Preview {
    CurrencyListView(databaseURL: URL(string: "path/to/database")!)
}

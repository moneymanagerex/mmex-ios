//
//  CurrencyListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/17.
//

import SwiftUI

struct CurrencyListView: View {
    let databaseURL: URL
    @State private var currencies: [Currency] = []
    @State private var newCurrency = Currency.empty
    @State private var isPresentingCurrencyAddView = false
    
    private var repository: CurrencyRepository
    
    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.repository = DataManager(databaseURL: databaseURL).getCurrencyRepository()
    }
    
    var body: some View {
        NavigationStack {
            List(currencies) { currency in
                NavigationLink(destination: CurrencyDetailView(currency: currency, databaseURL: databaseURL)) {
                    HStack {
                        Text(currency.name)
                        Spacer()
                        Text(currency.symbol)
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
                newCurrency = Currency.empty
            }
        }
    }
    
    func loadCurrencies() {
        // Fetch accounts using repository and update the view
        DispatchQueue.global(qos: .background).async {
            let loadedCurrencies = repository.loadCurrencies()
            
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.currencies = loadedCurrencies
            }
        }
    }

    func addCurrency(_ currency: inout Currency) {
        if repository.addCurrency(currency: &currency) {
            self.loadCurrencies()
        } else {
            // TODO
        }
    }
}

#Preview {
    CurrencyListView(databaseURL: URL(string: "path/to/database")!)
}

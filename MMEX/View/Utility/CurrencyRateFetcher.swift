//
//  CurrencyRateFetcher.swift
//  MMEX
//
//  Created by Lisheng Guan on 2025/2/25.
//

import Foundation

// Define the structure of the response to match the JSON structure
struct CurrencyRateResponse: Decodable {
    let result: String
    let base_code: String
    let conversion_rates: [String: Double] // The conversion rates dictionary
}

struct CurrencyRateFetcher {
    
    private var baseCurrency: String
    private let validBaseCurrencies = ["USD", "EUR", "GBP", "CNY", "AUD"]
    
    // Computed property to dynamically check if the base currency is valid
    var isValid: Bool {
        return validBaseCurrencies.contains(baseCurrency)
    }
    
    // Default initializer with "USD" as the base currency
    init(baseCurrency: String = "USD") {
        self.baseCurrency = baseCurrency
    }
    
    // Method to update the base currency
    mutating func setBaseCurrency(_ newBaseCurrency: String) {
        self.baseCurrency = newBaseCurrency
    }
    
    // Function to fetch conversion rate for a given target currency
    func fetchConversionRate(for targetCurrency: String) async throws -> Double {
        guard isValid else {
            throw NSError(domain: "CurrencyRateFetcher", code: 400, userInfo: [NSLocalizedDescriptionKey: "Base currency is invalid."])
        }
        
        let urlString = "https://moneymanagerex.org/currency/data/latest_\(baseCurrency).json"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(CurrencyRateResponse.self, from: data)
        
        guard let directRate = response.conversion_rates[targetCurrency] else {
            throw NSError(domain: "CurrencyRateFetcher", code: 404, userInfo: [NSLocalizedDescriptionKey: "Currency not found."])
        }
        
        // If the base currency is the same as the response, direct rate is already provided
        let indirectRate = 1.0 / directRate
        
        return indirectRate
    }
}

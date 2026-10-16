//
//  CategoryData.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import Foundation
import SQLite

struct CategoryData: DataProtocol {
    var id       : DataId = .void
    var name     : String = ""
    var active   : Bool   = false
    var parentId : DataId = .void
    
    // unique(name, parentId)
}

extension CategoryData {
    static let dataName = ("Category", "Categories")

    func shortDesc() -> String {
        "#\(self.id.value): \(self.name)"
    }

    mutating func copy() {
        id   = .void
        name = Self.copy(of: name)
    }

    mutating func resolveConstraint(conflictingWith existing: CategoryData? = nil) -> Bool {
        /// TODO column level
        self.name = "\(self.name):\(self.id)"
        return true
    }
}

extension CategoryData {
    var isRoot: Bool { parentId.isVoid }
}

extension CategoryData {
    static let categoryToSFSymbol: [String: String] = [
        "Unknown": "list.bullet.rectangle.fill",
        "Auto": "car.fill",
        "Automobile": "car",
        "Bills": "doc.text.fill",
        "Books": "book.fill",
        "Cable TV": "tv.fill",
        "Clothing": "tshirt.fill",
        "Dental": "mouth.fill",
        "Dining out": "fork.knife",
        "Education": "graduationcap.fill",
        "Electricity": "bolt.fill",
        "Eyecare": "eyeglasses",
        "Food": "cart.fill",
        "Furnishing": "bed.double.fill",
        "Gas": "fuelpump.fill", // Assuming "Gas" refers to fuel
        "Gas Utility": "flame.fill",
        "Gifts": "gift.fill",
        "Groceries": "cart",
        "Health": "heart.fill",
        "Healthcare": "cross.case.fill",
        "Home": "house.fill",
        "Homeneeds": "wrench.and.screwdriver.fill",
        "House Tax": "building.columns.fill",
        "Income": "dollarsign.circle.fill",
        "Income Tax": "doc.text.magnifyingglass",
        "Insurance": "shield.fill",
        "Internet": "wifi",
        "Investment Income": "chart.bar.fill",
        "Leisure": "gamecontroller.fill",
        "Life": "person.fill",
        "Lodging": "bed.double.fill",
        "Magazines": "book.circle.fill",
        "Maintenance": "wrench.fill",
        "Miscellaneous": "questionmark.circle.fill",
        "Movies": "film.fill",
        "Other Expenses": "ellipsis.circle.fill",
        "Other Income": "plus.circle.fill",
        "Others": "ellipsis.circle.fill", // Repeated for multiple "Others"
        "Parking": "parkingsign.circle.fill",
        "Physician": "stethoscope",
        "Prescriptions": "pills.fill",
        "Registration": "person.badge.plus.fill",
        "Reimbursement/Refunds": "arrow.uturn.left.circle.fill",
        "Rent": "house.circle.fill",
        "Salary": "dollarsign.circle",
        "Sightseeing": "binoculars.fill",
        "Taxes": "doc.text.magnifyingglass",
        "Telephone": "phone.fill",
        "Transfer": "arrow.right.arrow.left.circle.fill",
        "Travel": "airplane",
        "Tuition": "graduationcap.circle.fill",
        "Vacation": "sun.max.fill",
        "Video Rental": "play.rectangle.fill",
        "Water": "drop.fill",
        "Water Tax": "building.columns.fill"
    ]

    static let predefinedSymbols: [String] = Array(categoryToSFSymbol.values)
}

extension CategoryData {
    static let sampleData: [CategoryData] = [
        CategoryData(id: 1, name: "Income", active: true, parentId: .void),
        CategoryData(id: 2, name: "Salary", active: true, parentId: 1),
        CategoryData(id: 3, name: "Freelance", active: true, parentId: 1),
        CategoryData(id: 4, name: "Home", active: true, parentId: .void),
        CategoryData(id: 5, name: "Utilities", active: true, parentId: 4),
        CategoryData(id: 6, name: "Internet", active: true, parentId: 4),
        CategoryData(id: 7, name: "Food", active: true, parentId: .void),
        CategoryData(id: 8, name: "Groceries", active: true, parentId: 7),
        CategoryData(id: 9, name: "Transport", active: true, parentId: .void),
        CategoryData(id: 10, name: "Transit", active: true, parentId: 9),
        CategoryData(id: 11, name: "Leisure", active: true, parentId: .void),
        CategoryData(id: 12, name: "Dining", active: true, parentId: 11),
        CategoryData(id: 13, name: "Investments", active: true, parentId: .void),
        CategoryData(id: 14, name: "Brokerage", active: true, parentId: 13),
        CategoryData(id: 15, name: "Transfers", active: true, parentId: .void),
        CategoryData(id: 16, name: "Savings Move", active: true, parentId: 15),
    ]
    static var sampleDataIds : [DataId] {
        sampleData.map { $0.id }
    }
}

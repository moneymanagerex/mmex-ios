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
        CategoryData(id: 1, name: "Bills",     active: true, parentId: .void),
        CategoryData(id: 2, name: "Telephone", active: true, parentId: 1),
    ]
    static var sampleDataIds : [DataId] {
        sampleData.map { $0.id }
    }
}

//
//  Category.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import Foundation
import SQLite

struct Category: ExportableEntity {
    var id       : Int64
    var name     : String
    var active   : Bool
    var parentId : Int64
    
    init(
        id       : Int64  = 0,
        name     : String = "",
        active   : Bool   = false,
        parentId : Int64  = 0
    ) {
        self.id       = id
        self.name     = name
        self.active   = active
        self.parentId = parentId
    }
}

extension Category {
    var isRoot: Bool {
        return parentId <= 0
    }
}

extension Category: ModelProtocol {
    static let modelName = "Category"

    func shortDesc() -> String {
        "\(self.name), \(self.id)"
    }
}

extension Category {
    static let categoryToSFSymbol: [String: String] = [
        "Unknown": "camera.metering.unknown",
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
}

extension Category {
    static let sampleData: [Category] = [
        Category(id: 1, name: "root cateogry",     active: true, parentId: -1),
        Category(id: 2, name: "non-root category", active: true, parentId: 1),
    ]
}

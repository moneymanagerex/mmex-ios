//
//  Category.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import Foundation
import SQLite

struct Category: ExportableEntity {
    var id: Int64        // CATEGID INTEGER PRIMARY KEY
    var name: String     // CATEGNAME TEXT COLLATE NOCASE
    var active: Bool?    // ACTIVE INTEGER
    var parentId: Int64? // PARENTID INTEGER
                         // UNIQUE(CATEGNAME, PARENTID)
}

extension Category {
    // empty category
    static var empty : Category { Category(
        id: 1, name: "cateogry name", active: true, parentId: nil
    ) }

    var isRoot: Bool {
        return parentId == nil || parentId! <= 0
    }
}

extension Category {
    static let sampleData: [Category] = [
        Category(id: 1, name: "root cateogry",     active: true, parentId: nil),
        Category(id: 2, name: "non-root category", active: true, parentId: 1),
    ]
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

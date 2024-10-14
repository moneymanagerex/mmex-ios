//
//  Theme.swift
//  MMEX
//
//  Created 2024-10-04 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

protocol ThemeProtocol: Equatable {
}

struct Theme: ThemeProtocol {
    var tab   = TabTheme()
    var group = GroupTheme()
    var item  = ItemTheme()
    var field = FieldTheme()
}

struct BadgeCount: View {
    var count: Int
    var body: some View {
        Text("\(count)")
            .font(.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(.gray, in: .capsule)
    }
}

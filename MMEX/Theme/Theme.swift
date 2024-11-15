//
//  Theme.swift
//  MMEX
//
//  2024-10-04: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

protocol ThemeProtocol: Equatable {
}

struct Theme: ThemeProtocol {
    var appearance : Appearance = .defaultValue
    var tab        : TabTheme   = .init()
    var group      : GroupTheme = .init()
    var item       : ItemTheme  = .init()
    var field      : FieldTheme = .init()
}

extension Theme {
    init(fromPreferences: Void) {
        self.appearance = .init(fromPreferences: ())
        self.tab        = .init(fromPreferences: ())
        self.group      = .init(fromPreferences: ())
        self.item       = .init(fromPreferences: ())
        self.field      = .init(fromPreferences: ())
    }
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

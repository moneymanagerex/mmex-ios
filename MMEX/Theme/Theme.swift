//
//  Theme.swift
//  MMEX
//
//  2024-10-04: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

protocol ThemeProtocol {
}

struct Theme: ThemeProtocol {
    @Preference var appearance: Appearance = .defaultValue

    var tab   : TabTheme   = .init()
    var group : GroupTheme = .init()
    var item  : ItemTheme  = .init()
    var field : FieldTheme = .init()
}

extension Theme {
    init(prefix: String?) {
        self.$appearance = prefix?.appending("appearance")

        self.tab   = .init(prefix: prefix?.appending("tab."))
        self.group = .init(prefix: prefix?.appending("group."))
        self.item  = .init(prefix: prefix?.appending("item."))
        self.field = .init(prefix: prefix?.appending("field."))
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

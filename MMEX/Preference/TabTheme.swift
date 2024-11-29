//
//  TabTheme.swift
//  MMEX
//
//  Created 2024-10-05 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

struct TabTheme {
    enum Layout: String, ChoiceProtocol {
        case icon     = "Icon"
        case iconText = "Icon and Text"
        static let defaultValue = Self.iconText
    }

    @StoredPreference var layout: Layout = .defaultValue
}

extension TabTheme {
    init(prefix: String?) {
        self.$layout = prefix?.appending("layout")
    }
}

extension TabTheme {
    @ViewBuilder
    func iconText(icon: String, text: String) -> some View {
        Label(self.layout == .iconText ? text : "", systemImage: icon)
    }
}

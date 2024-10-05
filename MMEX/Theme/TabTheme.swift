//
//  TabTheme.swift
//  MMEX
//
//  Created 2024-10-05 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

struct TabTheme {
    enum Choice: String, EnumCollateNoCase {
        case icon     = "Icon"
        case iconText = "Icon and Text"
        static let defaultValue = Self.iconText
    }

    var choice = Choice.defaultValue
}

extension TabTheme {
    func iconText(icon: String, text: String) -> some View {
        VStack{
            Image(systemName: icon)
            if self.choice == .iconText { Text(text) }
        }
    }
}

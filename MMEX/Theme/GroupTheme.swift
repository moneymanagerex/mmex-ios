//
//  FieldTheme.swift
//  MMEX
//
//  Created 2024-10-04 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

struct GroupTheme {
    enum Choice: String, EnumCollateNoCase {
        case foldName = "Fold Name space"
        case nameFold = "Name space Fold"
        static let defaultValue = Self.foldName
    }

    var choice = Self.Choice.defaultValue
}

extension GroupTheme {
    func fold(_ open: Bool) -> some View {
        Image(systemName: open ? "chevron.down.circle.fill" : "chevron.right.circle")
            .foregroundColor(.gray)
    }

    func hstack<NameView: View>(
        _ open: Bool,
        @ViewBuilder name nameView: @escaping () -> NameView
    ) -> some View {
        return Group {
            switch choice {
            case .foldName:
                HStack {
                    fold(open)
                    nameView()
                        .font(.subheadline)
                        .padding(.leading)

                    Spacer()
                }
            case .nameFold:
                HStack {
                    nameView()
                        .font(.subheadline)
                        .padding(.leading)

                    Spacer()
                    fold(open)
                }
            }
        }
    }
}

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
                        .font(.headline.smallCaps())
                        .foregroundColor(.blue)
                        .padding(.leading)
                    
                    Spacer()
                }
            case .nameFold:
                HStack {
                    nameView()
                        .font(.headline.smallCaps())
                        .foregroundColor(.blue)
                        .padding(.leading)
                    
                    Spacer()
                    fold(open)
                }
            }
        }
    }
    
    /*
    func section<NameView: View>(
        _ isExpanded: @autoclosure () -> Bool?,
        @ViewBuilder name nameView: @escaping () -> NameView
    ) -> some View {
        Section(header: HStack {
            Button(action: {
                isExpanded[inUse]?.toggle()
            }) {
                env.theme.group.hstack(
                    isExpanded[inUse] == true
                ) {
                    Text(inUse ? "Used" : "Not Used")
                }
            }
        }) {
            if isExpanded[inUse] == true {
                ForEach($allCurrencyData) { $currency in
                    if (env.currencyCache[currency.id] != nil) == inUse {
                        NavigationLink(destination: CurrencyDetailView(
                            currency: $currency
                        ) ) { HStack {
                            Text(currency.name)
                            Spacer()
                            Text(currency.symbol)
                        } }
                    }
                }
            }
        }.listSectionSpacing(10)
    }
     */
}

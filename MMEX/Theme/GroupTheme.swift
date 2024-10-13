//
//  FieldTheme.swift
//  MMEX
//
//  Created 2024-10-04 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

struct GroupTheme {
    enum Layout: String, EnumCollateNoCase {
        case foldName = "Fold Name space Count"
        case nameFold = "Name space Count Fold"
        static let defaultValue = Self.foldName
    }

    var layout = Self.Layout.defaultValue
    var showCount: Bool = false
}

extension GroupTheme {
    func fold(_ isExpanded: Bool) -> some View {
        Image(systemName: isExpanded ? "chevron.down.circle.fill" : "chevron.right.circle")
            .foregroundColor(.gray)
    }
    
    func view<NameView: View>(
        @ViewBuilder name nameView: @escaping () -> NameView,
        count: Int? = nil,
        isExpanded: Bool
    ) -> some View {
        return Group {
            switch layout {
            case .foldName:
                HStack {
                    fold(isExpanded)
                    nameView()
                        .font(.headline.smallCaps())
                        .foregroundColor(.blue)
                        .padding(.leading)
                    
                    Spacer()
                    if showCount, let count {
                        BadgeCount(count: count)
                    }
                }
            case .nameFold:
                HStack {
                    nameView()
                        .font(.headline.smallCaps())
                        .foregroundColor(.blue)
                        .padding(.leading)
                    
                    Spacer()
                    if showCount, let count {
                        BadgeCount(count: count)
                    }
                    fold(isExpanded)
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
                env.theme.group.layout(
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

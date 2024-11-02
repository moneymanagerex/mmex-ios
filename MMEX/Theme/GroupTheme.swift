//
//  FieldTheme.swift
//  MMEX
//
//  Created 2024-10-04 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

struct GroupTheme: ThemeProtocol {
    enum Layout: String, EnumCollateNoCase {
        case foldName = "Fold Name space Count"
        case nameFold = "Name space Count Fold"
        static let defaultValue = Self.foldName
    }

    var layout = Self.Layout.defaultValue
    var showCount: Bool = true
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

    func manageItem<NameView: View, MainRepository: RepositoryProtocol>(
        @ViewBuilder name nameView: @escaping () -> NameView,
        count: LoadMainCount<MainRepository>
    ) -> some View {
        HStack {
            nameView()
                .font(.headline)
            Spacer()
            if showCount { switch count.state {
            case .ready:
                BadgeCount(count: count.value)
            case .loading:
                ProgressView()
            case .error:
                ProgressView().tint(.red)
            case .idle:
                EmptyView()
            } }
        }
    }
}

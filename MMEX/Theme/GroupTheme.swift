//
//  FieldTheme.swift
//  MMEX
//
//  Created 2024-10-04 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

struct GroupTheme: ThemeProtocol {
    enum Layout: String, PreferenceProtocol {
        case foldName = "Fold Name space Count"
        case nameFold = "Name space Count Fold"
        static let preferenceKey = "theme.group.layout"
        static let defaultValue = Self.foldName
    }
    
    enum ShowCount: String, PreferenceProtocol {
        case boolFalse = "FALSE"
        case boolTrue  = "TRUE"
        static let preferenceKey = "theme.group.showCount"
        static let defaultValue = Self.boolTrue
        
        var asBool: Bool {
            get { self == .boolTrue }
            set { self = newValue ? .boolTrue : .boolFalse }
        }
    }

    var layout = Self.Layout.defaultValue
    var showCount = Self.ShowCount.defaultValue
}

extension GroupTheme {
    init(fromPreferences: Void) {
        self.layout = Layout.loadPreference()
        self.showCount = ShowCount.loadPreference()
    }
}

extension GroupTheme {
    func fold(_ isExpanded: Bool) -> some View {
        Image(systemName: isExpanded ? "chevron.down.circle.fill" : "chevron.right.circle")
            .foregroundColor(.gray)
    }

    func view<NameView: View>(
        @ViewBuilder nameView: @escaping () -> NameView,
        count: Int? = nil,
        isExpanded: Bool? = nil
    ) -> some View {
        return Group {
            switch layout {
            case .foldName:
                HStack {
                    if let isExpanded {
                        fold(isExpanded)
                    }
                    nameView()
                        .font(.headline.smallCaps())
                        .foregroundColor(.accentColor)
                        //.padding(.leading)
                    
                    Spacer()
                    if showCount == .boolTrue, let count {
                        BadgeCount(count: count)
                    }
                }
            case .nameFold:
                HStack {
                    nameView()
                        .font(.headline.smallCaps())
                        .foregroundColor(.accentColor)
                        //.padding(.leading)
                    
                    Spacer()
                    if showCount == .boolTrue, let count {
                        BadgeCount(count: count)
                    }
                    if let isExpanded {
                        fold(isExpanded)
                    }
                }
            }
        }
    }

    func section<NameView: View, Content: View>(
        @ViewBuilder nameView: @escaping () -> NameView,
        count: Int? = nil,
        isExpanded: Binding<Bool>? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        Section(header: HStack {
            if let isExpanded {
                Button(action: { isExpanded.wrappedValue.toggle() }) {
                    self.view(
                        nameView: nameView,
                        count: count,
                        isExpanded: isExpanded.wrappedValue
                    )
                }
            } else {
                self.view(
                    nameView: nameView,
                    count: count
                )
            }
        } ) { if isExpanded == nil || isExpanded!.wrappedValue {
            content()
        } }
    }

    func manageItem<NameView: View, MainRepository: RepositoryProtocol>(
        @ViewBuilder nameView: @escaping () -> NameView,
        count: LoadMainCount<MainRepository>
    ) -> some View {
        HStack {
            nameView()
                .font(.headline)
            Spacer()
            if showCount == .boolTrue { switch count.state {
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

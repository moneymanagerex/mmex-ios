//
//  FieldTheme.swift
//  MMEX
//
//  Created 2024-10-04 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

struct GroupTheme {
    enum Layout: String, ChoiceProtocol {
        case foldName = "Fold Name space Count"
        case nameFold = "Name space Count Fold"
        static let defaultValue = Self.foldName
    }
    
    @StoredPreference var layout    : Layout   = .defaultValue
    @StoredPreference var showCount : BoolChoice = .boolTrue
}

extension GroupTheme {
    init(prefix: String? = nil) {
        self.$layout    = prefix?.appending("layout")
        self.$showCount = prefix?.appending("showCount")
    }
}

extension GroupTheme {
    @ViewBuilder
    static func fold(_ isExpanded: Bool) -> some View {
        Image(systemName: isExpanded ? "chevron.down.circle.fill" : "chevron.right.circle")
            .foregroundColor(.gray)
    }

    @ViewBuilder
    func view<NameView: View>(
        @ViewBuilder nameView: @escaping () -> NameView,
        count: Int? = nil,
        isExpanded: Bool? = nil
    ) -> some View {
        switch layout {
        case .foldName:
            HStack {
                if let isExpanded {
                    Self.fold(isExpanded)
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
                    Self.fold(isExpanded)
                }
            }
        }
    }

    @ViewBuilder
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

    @ViewBuilder
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

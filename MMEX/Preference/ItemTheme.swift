//
//  FieldTheme.swift
//  MMEX
//
//  Created 2024-10-13 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

struct ItemTheme {
    enum Layout: String, ChoiceProtocol {
        case hstack = "HStack"
        case vstack = "VStack"
        static let defaultValue = Self.hstack
    }

    @StoredPreference var layout: Layout = .defaultValue
}

extension ItemTheme {
    init(prefix: String? = nil) {
        self.$layout = prefix?.appending("layout")
    }
}

extension ItemTheme {
    @ViewBuilder
    func view<NameView: View, InfoView: View>(
        @ViewBuilder nameView: @escaping () -> NameView,
        @ViewBuilder infoView: @escaping () -> InfoView
    ) -> some View {
        switch layout {
        case .hstack:
            HStack {
                nameView()
                    .font(.body)
                Spacer()
                infoView()
                    .font(.caption)
                //.border(.red)
            }
            .listRowInsets(.init())
            //.border(.red)
            .padding(.horizontal, 0)
        case .vstack:
            HStack{
                VStack(alignment: .leading, spacing: 4) {
                    nameView()
                        .font(.body)
                    //.border(.red)
                    //Spacer()
                    infoView()
                        .font(.caption)
                    //.border(.red)
                }
                Spacer()
            }
            .listRowInsets(.init())
            //.border(.red)
            .padding(.horizontal, 0)
        }
    }
}

extension ItemTheme {
    @ViewBuilder
    static func settings<NameView: View, InfoView: View>(
        @ViewBuilder nameView: @escaping () -> NameView,
        @ViewBuilder infoView: @escaping () -> InfoView
    ) -> some View {
        HStack {
            nameView()
                .font(.body)
            Spacer()
            infoView()
                .font(.body)
        }
    }
}

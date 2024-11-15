//
//  FieldTheme.swift
//  MMEX
//
//  Created 2024-10-13 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

struct ItemTheme: ThemeProtocol {
    enum Layout: String, PreferenceProtocol {
        case hstack = "HStack"
        case vstack = "VStack"
        static let preferenceKey = "theme.item.layout"
        static let defaultValue = Self.hstack
    }

    var layout = Self.Layout.defaultValue
}

extension ItemTheme {
    init(fromPreferences: Void) {
        self.layout = Layout.loadPreference()
    }
}

extension ItemTheme {
    func view<NameView: View, InfoView: View>(
        @ViewBuilder nameView: @escaping () -> NameView,
        @ViewBuilder infoView: @escaping () -> InfoView
    ) -> some View {
        return Group {
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
}

//
//  FieldTheme.swift
//  MMEX
//
//  Created 2024-10-04 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

struct FieldTheme {
    enum Choice: String, EnumCollateNoCase {
        case vstack = "VStack"
        static let defaultValue = Self.vstack
    }

    var choice = Self.Choice.defaultValue
}

extension FieldTheme {
    func text<ValueView: View>(
        _ edit: Bool,
        _ name: String?,
        @ViewBuilder valueView: @escaping () -> ValueView
    ) -> some View {
        return Group {
            switch choice {
            case .vstack:
                VStack(alignment: .leading, spacing: 4.0) {
                    if let name {
                        Text(name)
                            .font(.body.smallCaps())
                            .fontWeight(.thin)
                            .dynamicTypeSize(.small)
                            .padding(0)
                    }
                    valueView()
                        .padding(.top, 0.0)
                        .padding(.bottom, 0.0)
                        .disabled(!edit)
                }
                .padding(0)
            }
        }
    }

    func picker<ValueView: View>(
        _ edit: Bool,
        _ name: String?,
        @ViewBuilder valueView: @escaping () -> ValueView
    ) -> some View {
        return Group {
            switch choice {
            case .vstack:
                VStack(alignment: .leading, spacing: 4.0) {
                    if let name {
                        Text(name)
                            .font(.body.smallCaps())
                            .fontWeight(.thin)
                            .dynamicTypeSize(.small)
                            .padding(0)
                    }
                    valueView()
                        .padding(.top, -8)
                        .padding(.bottom, 0.0)
                        .disabled(!edit)
                        //.border(.black)
                        //.labelsHidden()
                        //.pickerStyle(SegmentedPickerStyle()) // Adjust the style of the picker as needed
                }
                .padding(0)
            }
        }
    }

    func toggle<ValueView: View>(
        _ edit: Bool,
        _ name: String?,
        @ViewBuilder valueView: @escaping () -> ValueView
    ) -> some View {
        return Group {
            switch choice {
            case .vstack:
                VStack(alignment: .leading, spacing: 4.0) {
                    if let name {
                        Text(name)
                            .font(.body.smallCaps())
                            .fontWeight(.thin)
                            .dynamicTypeSize(.small)
                            .padding(0)
                    }
                    valueView()
                        .padding(.top, -8)
                        .padding(.bottom, 0.0)
                        .disabled(!edit)
                }
                .padding(0)
            }
        }
    }
}

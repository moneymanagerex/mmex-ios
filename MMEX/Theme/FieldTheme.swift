//
//  FieldTheme.swift
//  MMEX
//
//  Created 2024-10-04 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

struct FieldTheme: ThemeProtocol {
    enum Layout: String, PreferenceProtocol {
        case vstack = "VStack"
        static let preferenceKey = "theme.field.layout"
        static let defaultValue = Self.vstack
    }

    var layout = Self.Layout.defaultValue
}

extension FieldTheme {
    init(fromPreferences: Void) {
        self.layout = Layout.loadPreference()
    }
}

extension FieldTheme {
    func vstackName(_ name: String) -> some View {
        Text(name)
            .font(.body.smallCaps())
            .fontWeight(.thin)
            .dynamicTypeSize(.small)
            .padding(0)
    }

    @ViewBuilder
    func valueOrHint(_ hint: String, text value: String?) -> some View {
        if let value, !value.isEmpty {
            Text(value)
        } else {
            Text(hint).foregroundColor(.gray)
        }
    }

    @ViewBuilder
    func valueOrError(_ error: String, text value: String?) -> some View {
        if let value, !value.isEmpty {
            Text(value)
        } else {
            Text(error).foregroundColor(.red).opacity(0.6)
        }
    }
}

extension FieldTheme {
    @ViewBuilder
    func view<ValueView: View>(
        _ edit: Bool, _ name: String,
        @ViewBuilder valueView: @escaping () -> ValueView
    ) -> some View {
        switch layout {
        case .vstack:
            VStack(alignment: .leading, spacing: 4.0) {
                vstackName(name)
                valueView()
                    .disabled(!edit)
            }
            .padding(0)
        }
        //.frame(maxWidth: .infinity)
        //.background(Color.red).overlay(
        //    GeometryReader { g in
        //        Text("\(g.size)")
        //    }
        //)
    }

    @ViewBuilder
    func view<EditView: View, ShowView: View>(
        _ edit: Bool, _ name: String,
        @ViewBuilder editView: @escaping () -> EditView,
        @ViewBuilder showView: @escaping () -> ShowView
    ) -> some View {
        switch layout {
        case .vstack:
            VStack(alignment: .leading, spacing: 4.0) {
                vstackName(name)
                if edit {
                    editView()
                } else {
                    showView()
                }
            }
            .padding(0)
        }
    }

    @ViewBuilder
    func view<EditView: View, ShowView: View>(
        _ edit: Bool, _ showOnEdit: Bool, _ name: String,
        @ViewBuilder editView: @escaping () -> EditView,
        @ViewBuilder showView: @escaping () -> ShowView
    ) -> some View {
        switch layout {
        case .vstack:
            HStack {
                VStack(alignment: .leading, spacing: 4.0) {
                    vstackName(name)
                    if !edit || showOnEdit {
                        showView()
                            .opacity(edit ? 0.5 : 1)
                    }
                }
                if edit {
                    Spacer()
                    editView()
                        .multilineTextAlignment(.trailing)
                }
            }
            .padding(0)
        }
    }
}

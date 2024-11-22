//
//  FieldTheme.swift
//  MMEX
//
//  Created 2024-10-04 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

struct FieldTheme: ThemeProtocol {
    enum Layout: String, EnumCollateNoCase {
        case vstack = "VStack"
        static let defaultValue = Self.vstack
    }

    @Preference var layout    : Layout = .defaultValue
    @Preference var noteLines : Int    = 4
    @Preference var codeLines : Int    = 8
}

extension FieldTheme {
    init(prefix: String? = nil) {
        self.$layout    = prefix?.appending("layout")
        self.$noteLines = prefix?.appending("noteLines")
        self.$codeLines = prefix?.appending("codeLines")
    }
}

extension FieldTheme {
    @ViewBuilder
    func vstackName(_ name: String) -> some View {
        if !name.isEmpty {
            Text(name)
                .font(.body.smallCaps())
                .fontWeight(.thin)
                .dynamicTypeSize(.small)
                .padding(0)
        }
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

extension FieldTheme {
    @ViewBuilder
    func notes(
        _ edit: Bool, _ name: String, _ text: Binding<String>
    ) -> some View {
        self.view(edit, name, editView: {
            TextEditor(text: text)
                .textInputAutocapitalization(.never)
                .frame(minHeight: 100, maxHeight: 400)
        }, showView: {
            self.valueOrHint("N/A", text: text.wrappedValue)
                .lineLimit(self.noteLines)
        } )
    }

    @ViewBuilder
    func code(
        _ edit: Bool, _ name: String, _ text: Binding<String>
    ) -> some View {
        self.view(edit, name, editView: {
            TextEditor(text: text)
                .font(.caption.monospaced())
                .textInputAutocapitalization(.never)
                .frame(minHeight: 100, maxHeight: 400)
        }, showView: {
            self.valueOrHint("N/A", text: text.wrappedValue)
                .font(.caption.monospaced())
                .lineLimit(self.codeLines)
        } )
    }
}

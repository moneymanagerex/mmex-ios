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
    func vstackName(_ name: String) -> some View {
        Text(name)
            .font(.body.smallCaps())
            .fontWeight(.thin)
            .dynamicTypeSize(.small)
            .padding(0)
    }

    func valueOrHint(_ hint: String, text value: String?) -> some View {
        Group {
            if let value, !value.isEmpty {
                Text(value)
            } else {
                Text(hint).foregroundColor(.gray)
            }
        }
    }

    func valueOrError(_ error: String, text value: String?) -> some View {
        return Group {
            if let value, !value.isEmpty {
                Text(value)
            } else {
                Text(error).foregroundColor(.red).opacity(0.5)
            }
        }
    }

    func text<ValueView: View>(
        _ edit: Bool,
        _ name: String,
        @ViewBuilder value valueView: @escaping () -> ValueView
    ) -> some View {
        return Group {
            switch choice {
            case .vstack:
                VStack(alignment: .leading, spacing: 4.0) {
                    vstackName(name)
                    valueView()
                        //.padding(.top, 0.0)
                        //.padding(.bottom, 0.0)
                        .disabled(!edit)
                }
                .padding(0)
            }
        }
        //.frame(maxWidth: .infinity)
        //.background(Color.red).overlay(
        //    GeometryReader { g in
        //        Text("\(g.size)")
        //    }
        //)
    }

    func text<EditView: View, ShowView: View>(
        _ edit: Bool,
        _ name: String,
        @ViewBuilder edit editView: @escaping () -> EditView,
        @ViewBuilder show showView: @escaping () -> ShowView
    ) -> some View {
        return Group {
            switch choice {
            case .vstack:
                VStack(alignment: .leading, spacing: 4.0) {
                    vstackName(name)
                    if edit {
                        editView()
                            //.padding(.top, 0.0)
                            //.padding(.bottom, 0.0)
                            //.disabled(!edit)
                    } else {
                        showView()
                            //.padding(.top, 0.0)
                            //.padding(.bottom, 0.0)
                    }
                }
                .padding(0)
            }
        }
    }

    func editor<EditView: View, ShowView: View>(
        _ edit: Bool,
        _ name: String,
        @ViewBuilder edit editView: @escaping () -> EditView,
        @ViewBuilder show showView: @escaping () -> ShowView
    ) -> some View {
        return Group {
            switch choice {
            case .vstack:
                VStack(alignment: .leading, spacing: 4.0) {
                    vstackName(name)
                    if edit {
                        editView()
                            .frame(minHeight: 20)
                            //.padding(.top, 0.0)
                            //.padding(.bottom, 0.0)
                            //.disabled(!edit)
                    } else {
                        showView()
                            //.padding(.top, 0.0)
                            //.padding(.bottom, 0.0)
                    }
                }
                .padding(0)
            }
        }
    }

    func picker<EditView: View, ShowView: View>(
        _ edit: Bool,
        _ name: String,
        @ViewBuilder edit editView: @escaping () -> EditView,
        @ViewBuilder show showView: @escaping () -> ShowView
    ) -> some View {
        return Group {
            switch choice {
            case .vstack:
                HStack {
                    VStack(alignment: .leading, spacing: 4.0) {
                        vstackName(name)
                        showView()
                            .opacity(edit ? 0 : 1)
                            //.padding(.top, 0.0)
                            //.padding(.bottom, 0.0)
                    }
                    if edit {
                        editView()
                            .disabled(!edit)
                            //.padding(.top, 0.0)
                            //.padding(.bottom, 0.0)
                            //.border(.black)
                            //.labelsHidden()
                            //.pickerStyle(SegmentedPickerStyle()) // Adjust the style of the picker as needed
                    }
                }
                .padding(0)
            }
        }
    }

    func toggle<EditView: View, ShowView: View>(
        _ edit: Bool,
        _ name: String,
        @ViewBuilder edit editView: @escaping () -> EditView,
        @ViewBuilder show showView: @escaping () -> ShowView
    ) -> some View {
        return Group {
            switch choice {
            case .vstack:
                HStack {
                    VStack(alignment: .leading, spacing: 4.0) {
                        vstackName(name)
                        showView()
                            //.padding(.top, 0.0)
                            //.padding(.bottom, 0.0)
                    }
                    if edit {
                        editView()
                            //.scaleEffect(0.9)
                            //.offset(x: 10)
                            .disabled(!edit)
                            //.padding(.top, 0.0)
                            //.padding(.bottom, 0.0)
                            //.border(.black)
                            //.labelsHidden()
                            //.pickerStyle(SegmentedPickerStyle()) // Adjust the style of the picker as needed
                    }
                }
                .padding(0)
            }
        }
    }

    func date<EditView: View, ShowView: View>(
        _ edit: Bool,
        _ name: String,
        @ViewBuilder edit editView: @escaping () -> EditView,
        @ViewBuilder show showView: @escaping () -> ShowView
    ) -> some View {
        return Group {
            switch choice {
            case .vstack:
                HStack {
                    VStack(alignment: .leading, spacing: 4.0) {
                        vstackName(name)
                        showView()
                            //.padding(.top, 0.0)
                            //.padding(.bottom, 0.0)
                    }
                    if edit {
                        Spacer()
                        editView()
                            .labelsHidden() // Hide the default label to save space
                            //.scaleEffect(0.9)
                            //.offset(x: 10)
                            .disabled(!edit)
                            //.padding(.top, 0.0)
                            //.padding(.bottom, 0.0)
                            //.border(.black)
                            //.labelsHidden()
                            //.pickerStyle(SegmentedPickerStyle()) // Adjust the style of the picker as needed
                    }
                }
                .padding(0)
            }
        }
    }
}

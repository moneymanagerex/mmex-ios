//
//  ThemeView.swift
//  MMEX
//
//  Created 2024-10-07 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct ThemeView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel

    @State var dateFormat: String = "%Y-%m-%d"
    @State var categoryDelimiter : String = ":"

    @State private var isExpanded: [String: Bool] = [
        "Tab Icons"    : true,
        "Group Layout" : true,
        "Item Layout"  : true,
        "Field Layout" : true,
    ]

    @State var focus: Bool = false
    @FocusState private var focusState: Int?

    let accentColor = Color.green

    var body: some View {
        List {
            Section() {
                HStack {
                    Text("Appearance")
                    Spacer()
                    Picker("", selection: $pref.theme.appearance) {
                        ForEach(Appearance.allCases) { choice in
                            Text(choice.rawValue).tag(choice)
                        }
                    }
                    .onChange(of: pref.theme.appearance) {
                        pref.theme.appearance.apply()
                    }
                }

                HStack {
                    Text("Numeric Keypad")
                    Spacer()
                    Toggle(isOn: $pref.theme.numericKeypad.asBool) { }
                }

                HStack {
                    Text("Date Format")
                    Spacer()
                    Text("\(dateFormat)")
                }

                HStack {
                    Text("Category Delimiter")
                    Spacer()
                    TextField("Default is ':'", text: $categoryDelimiter)
                        .keyboardType(pref.theme.textPad)
                        .focused($focusState, equals: 1)
                        .onChange(of: focusState) {
                            if focusState == nil { currencyDelimiterUpdate() }
                        }
                        .textInputAutocapitalization(.never)
                        // problem: trailing space is not visible
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 100)
                    Menu {
                        ForEach(categoryDelimiterSuggestion, id: \.self) { s in
                            Button("'\(s)'") {
                                categoryDelimiter = s
                                currencyDelimiterUpdate()
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.footnote)
                    }
                }

                HStack {
                    Text("Tab Icons")
                    Spacer()
                    Picker("", selection: $pref.theme.tab.layout) {
                        ForEach(TabTheme.Layout.allCases) { layout in
                            Text(layout.rawValue).tag(layout)
                        }
                    }
                }

                HStack {
                    Text("Group Count")
                    Spacer()
                    Toggle(isOn: $pref.theme.group.showCount.asBool) { }
                }
            }

            Section(header: HStack {
                Button(action: {
                    isExpanded["Group Layout"]?.toggle()
                }) {
                    pref.theme.group.view(
                        nameView: { Text("Group Layout") },
                        isExpanded: isExpanded["Group Layout"] == true
                    )
                }
            }) {
                if isExpanded["Group Layout"] == true {
                    VStack(spacing: 15) {
                        ForEach(GroupTheme.Layout.allCases) { layout in
                            Button(action: {
                                pref.theme.group.layout = layout
                            }) {
                                GroupTheme(layout: layout, showCount: pref.theme.group.showCount).view(
                                    nameView: { Text("Group Name") },
                                    count: 10,
                                    isExpanded: false
                                )
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8).stroke(
                                    pref.theme.group.layout == layout ? accentColor : .gray,
                                    lineWidth: pref.theme.group.layout == layout ? 3 : 1
                                )
                            )
                        }
                    }
                    .padding(0)
                }
            }

            Section(header: HStack {
                Button(action: {
                    isExpanded["Item Layout"]?.toggle()
                }) {
                    pref.theme.group.view(
                        nameView: { Text("Item Layout") },
                        isExpanded: isExpanded["Item Layout"] == true
                    )
                }
            }) {
                if isExpanded["Item Layout"] == true {
                    VStack(spacing: 15) {
                        ForEach(ItemTheme.Layout.allCases) { layout in
                            Button(action: {
                                pref.theme.item.layout = layout
                            }) {
                                ItemTheme(layout: layout).view(
                                    nameView: { Text("Item Name") },
                                    infoView: { Text("Item Info") }
                                )
                                .foregroundColor(.primary)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8).stroke(
                                    pref.theme.item.layout == layout ? accentColor : .gray,
                                    lineWidth: pref.theme.item.layout == layout ? 3 : 1
                                )
                            )
                        }
                    }
                    .padding(0)
                }
            }

            Section(header: HStack {
                Button(action: {
                    isExpanded["Field Layout"]?.toggle()
                }) {
                    pref.theme.group.view(
                        nameView: { Text("Field Layout") },
                        isExpanded: isExpanded["Field Layout"] == true
                    )
                }
            }) {
                if isExpanded["Field Layout"] == true {
                    VStack(spacing: 15) {
                        ForEach(FieldTheme.Layout.allCases) { layout in
                            Button(action: {
                                pref.theme.field.layout = layout
                            }) {
                                FieldTheme(layout: layout).view(false, "Field Name") {
                                    Text("Field Value")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.primary)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8).stroke(
                                    pref.theme.field.layout == layout ? accentColor : .gray,
                                    lineWidth: pref.theme.field.layout == layout ? 3 : 1
                                )
                            )
                        }
                    }
                }
            }
        }
        .listSectionSpacing(10)

        .scrollDismissesKeyboard(.immediately)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                KeyboardFocus(focus: $focus)
            }
        }
        .keyboardState(focus: $focus, focusState: $focusState)

        .onAppear {
            categoryDelimiter = pref.theme.categoryDelimiter
        }
    }

    var categoryDelimiterSuggestion: [String] { [
        ".",
        ":", " : ",
        "/", " / ",
        " ▶ ", " ❯ ",
    ] }

    func currencyDelimiterUpdate() {
        if categoryDelimiter.isEmpty { categoryDelimiter = ":" }
        guard categoryDelimiter != pref.theme.categoryDelimiter else { return }
        pref.theme.categoryDelimiter = categoryDelimiter
        vm.categoryList.evalPath.unload()
    }
}

#Preview {
    MMEXPreview.settings("Theme") { pref, vm in
        ThemeView()
    }
}

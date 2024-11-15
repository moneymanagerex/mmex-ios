//
//  SettingsThemeView.swift
//  MMEX
//
//  Created 2024-10-07 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct SettingsThemeView: View {
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel

    @State var dateFormat: String = "%Y-%m-%d"
    @State var categoryDelimiter : String = ":"

    @State private var isExpanded: [String: Bool] = [
        "Tab Icons"    : true,
        "Group Layout" : true,
        "Item Layout"  : true,
        "Field Layout" : true,
    ]
    @FocusState private var categoryDelimiterFocus: Bool

    let accentColor = Color.green

    var body: some View {
        List {
            Section() {
                HStack {
                    Text("Appearance")
                    Spacer()
                    Picker("", selection: $env.theme.appearance) {
                        ForEach(Appearance.allCases) { choice in
                            Text(choice.rawValue).tag(choice)
                        }
                    }
                    .onChange(of: env.theme.appearance) {
                        env.theme.appearance.apply()
                    }
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
                        .focused($categoryDelimiterFocus)
                        .onChange(of: categoryDelimiterFocus) {
                            if !categoryDelimiterFocus { currencyDelimiterUpdate() }
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
                    Picker("", selection: $env.theme.tab.layout) {
                        ForEach(TabTheme.Layout.allCases) { layout in
                            Text(layout.rawValue).tag(layout)
                        }
                    }
                }

                HStack {
                    Text("Group Count")
                    Spacer()
                    Toggle(isOn: $env.theme.group.showCount.asBool) { }
                }
            }

            Section(header: HStack {
                Button(action: {
                    isExpanded["Group Layout"]?.toggle()
                }) {
                    env.theme.group.view(
                        nameView: { Text("Group Layout") },
                        isExpanded: isExpanded["Group Layout"] == true
                    )
                }
            }) {
                if isExpanded["Group Layout"] == true {
                    VStack(spacing: 15) {
                        ForEach(GroupTheme.Layout.allCases) { layout in
                            Button(action: {
                                env.theme.group.layout = layout
                            }) {
                                GroupTheme(layout: layout, showCount: env.theme.group.showCount).view(
                                    nameView: { Text("Group Name") },
                                    count: 10,
                                    isExpanded: false
                                )
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8).stroke(
                                    env.theme.group.layout == layout ? accentColor : .gray,
                                    lineWidth: env.theme.group.layout == layout ? 3 : 1
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
                    env.theme.group.view(
                        nameView: { Text("Item Layout") },
                        isExpanded: isExpanded["Item Layout"] == true
                    )
                }
            }) {
                if isExpanded["Item Layout"] == true {
                    VStack(spacing: 15) {
                        ForEach(ItemTheme.Layout.allCases) { layout in
                            Button(action: {
                                env.theme.item.layout = layout
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
                                    env.theme.item.layout == layout ? accentColor : .gray,
                                    lineWidth: env.theme.item.layout == layout ? 3 : 1
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
                    env.theme.group.view(
                        nameView: { Text("Field Layout") },
                        isExpanded: isExpanded["Field Layout"] == true
                    )
                }
            }) {
                if isExpanded["Field Layout"] == true {
                    VStack(spacing: 15) {
                        ForEach(FieldTheme.Layout.allCases) { layout in
                            Button(action: {
                                env.theme.field.layout = layout
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
                                    env.theme.field.layout == layout ? accentColor : .gray,
                                    lineWidth: env.theme.field.layout == layout ? 3 : 1
                                )
                            )
                        }
                    }
                }
            }
        }
        .navigationTitle("Theme")
        .listSectionSpacing(10)
        .scrollDismissesKeyboard(.immediately)
        .onAppear {
            categoryDelimiter = env.theme.categoryDelimiter
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
        guard categoryDelimiter != env.theme.categoryDelimiter else { return }
        env.theme.categoryDelimiter = categoryDelimiter
        vm.categoryList.path.unload()
    }
}

#Preview {
    let env = EnvironmentManager.sampleData
    SettingsThemeView(
        vm: ViewModel(env: env)
    )
    .environmentObject(env)
}

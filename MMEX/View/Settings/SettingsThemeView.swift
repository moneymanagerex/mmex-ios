//
//  SettingsThemeView.swift
//  MMEX
//
//  Created 2024-10-07 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct SettingsThemeView: View {
    @EnvironmentObject var env: EnvironmentManager

    @State private var isExpanded: [String: Bool] = [
        "Tab Icons"    : true,
        "Group Layout" : true,
        "Item Layout"  : true,
        "Field Layout" : true,
    ]

    var body: some View {
        List {
            Section() {
                HStack {
                    Text("Tab Icons")
                    Spacer()
                    Picker("", selection: $env.theme.tab.layout) {
                        ForEach(TabTheme.Layout.allCases) { layout in
                            Text(layout.rawValue).tag(layout)
                        }
                    }
//                    .onChange(of: tabChoice) { _, newChoice in
//                        env.theme.tab.layout = newChoice
//                    }
                }
            }

            Section(header: HStack {
                Button(action: {
                    isExpanded["Group Layout"]?.toggle()
                }) {
                    env.theme.group.view(isExpanded["Group Layout"] == true) {
                        Text("Group Layout")
                    }
                }
            }) {
                if isExpanded["Group Layout"] == true {
                    VStack(spacing: 15) {
                        ForEach(GroupTheme.Layout.allCases) { layout in
                            Button(action: {
                                env.theme.group.layout = layout
                            }) {
                                GroupTheme(layout: layout).view(false) {
                                    Text("Group Name")
                                }
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8).stroke(
                                    env.theme.group.layout == layout ? .blue : .gray,
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
                    env.theme.group.view(isExpanded["Item Layout"] == true) {
                        Text("Item Layout")
                    }
                }
            }) {
                if isExpanded["Item Layout"] == true {
                    VStack(spacing: 15) {
                        ForEach(ItemTheme.Layout.allCases) { layout in
                            Button(action: {
                                env.theme.item.layout = layout
                            }) {
                                ItemTheme(layout: layout).view(
                                    name: { Text("Item Name") },
                                    info: { Text("Item Info") }
                                )
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8).stroke(
                                    env.theme.item.layout == layout ? .blue : .gray,
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
                    env.theme.group.view(isExpanded["Field Layout"] == true) {
                        Text("Field Layout")
                    }
                }
            }) {
                if isExpanded["Field Layout"] == true {
                    VStack(spacing: 15) {
                        ForEach(FieldTheme.Layout.allCases) { layout in
                            Button(action: {
                                env.theme.field.layout = layout
                            }) {
                                FieldTheme(layout: layout).text(false, "Field Name") {
                                    Text("N/A")
                                } show: {
                                    Text("Field Value")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .foregroundColor(.primary)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8).stroke(
                                    env.theme.field.layout == layout ? .blue : .gray,
                                    lineWidth: env.theme.field.layout == layout ? 3 : 1
                                )
                            )
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsThemeView(
    )
    .environmentObject(EnvironmentManager.sampleData)
}

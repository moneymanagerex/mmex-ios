//
//  SettingsThemeView.swift
//  MMEX
//
//  Created 2024-10-07 by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct SettingsThemeView: View {
    @EnvironmentObject var env: EnvironmentManager

    @AppStorage("appearance") private var appearance: Int = UIUserInterfaceStyle.unspecified.rawValue

    @State private var isExpanded: [String: Bool] = [
        "Tab Icons"    : true,
        "Group Layout" : true,
        "Item Layout"  : true,
        "Field Layout" : true,
    ]

    let accentColor = Color.green

    var body: some View {
        List {
            Section() {
                Picker("Appearance", selection: $appearance) {
                    Text("System").tag(UIUserInterfaceStyle.unspecified.rawValue)
                    Text("Light").tag(UIUserInterfaceStyle.light.rawValue)
                    Text("Dark").tag(UIUserInterfaceStyle.dark.rawValue)
                }
                .pickerStyle(NavigationLinkPickerStyle())
                .onChange(of: appearance) {
                    Appearance.apply(appearance)
                }

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
                HStack {
                    Text("Show Count")
                    Spacer()
                    Toggle(isOn: $env.theme.group.showCount) { }
                }
            }

            Section(header: HStack {
                Button(action: {
                    isExpanded["Group Layout"]?.toggle()
                }) {
                    env.theme.group.view(
                        name: { Text("Group Layout") },
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
                                    name: { Text("Group Name") },
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
                        name: { Text("Item Layout") },
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
                                    name: { Text("Item Name") },
                                    info: { Text("Item Info") }
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
                        name: { Text("Field Layout") },
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
    }
}

enum Appearance {
    static func apply(_ appearance: Int) {
        //log.debug("DEBUG: appearance: \(appearance)")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: appearance) ?? .unspecified
                window.reloadInputViews()
            }
        }
    }
}

#Preview {
    SettingsThemeView(
    )
    .environmentObject(EnvironmentManager.sampleData)
}

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
        "Tab"   : true,
        "Group" : true,
        "Field" : true,
    ]

    var body: some View {
        List {
            Section() {
                HStack {
                    Text("Tab icons")
                    Spacer()
                    Picker("", selection: $env.theme.tab.choice) {
                        ForEach(TabTheme.Choice.allCases) { choice in
                            Text(choice.rawValue).tag(choice)
                        }
                    }
//                    .onChange(of: tabChoice) { _, newChoice in
//                        env.theme.tab.choice = newChoice
//                    }
                }
            }

            Section(header: HStack {
                Button(action: {
                    isExpanded["Group"]?.toggle()
                }) {
                    env.theme.group.hstack(isExpanded["Group"] == true) {
                        Text("Group")
                    }
                }
            }) {
                if isExpanded["Group"] == true {
                    VStack(spacing: 15) {
                        ForEach(GroupTheme.Choice.allCases) { choice in
                            Button(action: {
                                env.theme.group.choice = choice
                            }) {
                                GroupTheme(choice: choice).hstack(false) {
                                    Text("Group Name")
                                }
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8).stroke(
                                    env.theme.group.choice == choice ? .red : .gray,
                                    lineWidth: env.theme.group.choice == choice ? 3 : 1
                                )
                            )
                        }
                    }
                    .padding(0)
                }
            }

            Section(header: HStack {
                Button(action: {
                    isExpanded["Field"]?.toggle()
                }) {
                    env.theme.group.hstack(isExpanded["Field"] == true) {
                        Text("Field")
                    }
                }
            }) {
                if isExpanded["Field"] == true {
                    VStack(spacing: 15) {
                        ForEach(FieldTheme.Choice.allCases) { choice in
                            Button(action: {
                                env.theme.field.choice = choice
                            }) {
                                FieldTheme(choice: choice).text(false, "Field Name") {
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
                                    env.theme.field.choice == choice ? .red : .gray,
                                    lineWidth: env.theme.field.choice == choice ? 3 : 1
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

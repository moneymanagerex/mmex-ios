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
        "Field Layout" : true,
    ]

    var body: some View {
        List {
            Section() {
                HStack {
                    Text("Tab Icons")
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
                    isExpanded["Group Layout"]?.toggle()
                }) {
                    env.theme.group.hstack(isExpanded["Group Layout"] == true) {
                        Text("Group Layout")
                    }
                }
            }) {
                if isExpanded["Group Layout"] == true {
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
                                    env.theme.group.choice == choice ? .blue : .gray,
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
                    isExpanded["Field Layout"]?.toggle()
                }) {
                    env.theme.group.hstack(isExpanded["Field Layout"] == true) {
                        Text("Field Layout")
                    }
                }
            }) {
                if isExpanded["Field Layout"] == true {
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
                                    env.theme.field.choice == choice ? .blue : .gray,
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

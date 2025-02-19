//
//  ReportFormView.swift
//  MMEX
//
//  2024-11-23: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct ReportFormView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @Binding var focus: Bool
    @Binding var data: ReportData
    @State var edit: Bool

    @FocusState var focusState: Int?

    var body: some View {
        Group {
            Section {
                pref.theme.field.view(edit, "Name", editView: {
                    TextField("Shall not be empty!", text: $data.name)
                        .focused($focusState, equals: 1)
                        .keyboardType(pref.theme.textPad)
                        .textInputAutocapitalization(.words)
                }, showView: {
                    pref.theme.field.valueOrError("Shall not be empty!", text: data.name)
                } )
                
                pref.theme.field.view(edit, "Group Name", editView: {
                    TextField("N/A", text: $data.groupName)
                        .focused($focusState, equals: 2)
                        .keyboardType(pref.theme.textPad)
                        .textInputAutocapitalization(.words)
                }, showView: {
                    pref.theme.field.valueOrHint("N/A", text: data.groupName)
                } )
                
                pref.theme.field.view(edit, true, "Active", editView: {
                    Toggle(isOn: $data.active) { }
                }, showView: {
                    Text(data.active ? "Yes" : "No")
                } )
            }
            
            Section("Description") {
                pref.theme.field.notes(edit, "", $data.description)
                    .focused($focusState, equals: 3)
                    .keyboardType(pref.theme.textPad)
            }
            
            Section("SQL Content") {
                pref.theme.field.code(edit, "", $data.sqlContent)
                    .focused($focusState, equals: 4)
                    .keyboardType(pref.theme.textPad)
            }
            
            Section("Lua Content") {
                pref.theme.field.code(edit, "", $data.luaContent)
                    .focused($focusState, equals: 5)
                    .keyboardType(pref.theme.textPad)
            }
            
            Section("Template Content") {
                pref.theme.field.code(edit, "", $data.templateContent)
                    .focused($focusState, equals: 6)
                    .keyboardType(pref.theme.textPad)
            }

            Section("Report Preview") {
                pref.theme.field.view(edit, "", editView: {}
                                      , showView: {
                    let reportResult = vm.runReport(report: data)
                    ReportPreviewView(reportResult: reportResult)
                })
            }
        }
        .keyboardState(focus: $focus, focusState: $focusState)
    }
}

struct ReportPreviewView: View {
    let reportResult: ReportResult

    var body: some View {
        if reportResult.columnNames.isEmpty {
            Text("No data available")
                .italic()
        } else {
            // Vertical scroll
            ScrollView(.vertical) {
                // Horizontal scroll container
                ScrollView(.horizontal) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header Row
                        HStack(spacing: 0) {
                            ForEach(reportResult.columnNames, id: \.self) { column in
                                Text(column)
                                    .font(.subheadline)
                                    .padding(10)
                                    .frame(minWidth: 120, maxWidth: .infinity, alignment: .leading)  // Fixed column width
                                    .background(Color.gray.opacity(0.2))  // Header background
                                    .border(Color.gray, width: 0.5)
                                    .multilineTextAlignment(.leading)  // Align text to the left
                            }
                        }

                        // Data Rows
                        ForEach(reportResult.rows, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(reportResult.columnNames, id: \.self) { column in
                                    Text(row[column] ?? "N/A")
                                        .padding(10)
                                        .frame(minWidth: 120, maxWidth: .infinity, alignment: .leading)  // Fixed column width
                                        .border(Color.gray, width: 0.5)  // Cell border
                                        .multilineTextAlignment(.leading)  // Align text to the left
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)  // Ensure the table stretches to full width
                }
                .padding(.vertical)
            }
        }
    }
}

#Preview("#\(ReportData.sampleData[0].id) (read)") {
    let data = ReportData.sampleData[0]
    MMEXPreview.manageRead(data) { $focus, $data, edit in ReportFormView(
        focus: $focus,
        data: $data,
        edit: edit
    ) }
}

#Preview("#\(ReportData.sampleData[0].id) (edit)") {
    let data = ReportData.sampleData[0]
    MMEXPreview.manageEdit(data) { $focus, $data, edit in ReportFormView(
        focus: $focus,
        data: $data,
        edit: edit
    ) }
}

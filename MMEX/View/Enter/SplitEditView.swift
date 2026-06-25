//
//  SplitEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/18.
//

import SwiftUI

struct SplitEditView: View {
    @Binding var split: JournalSplitData
    var onSave: (JournalSplitData) -> Void
    var onDelete: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var vm: ViewModel
    @EnvironmentObject var pref: Preference

    var body: some View {
        NavigationStack {
            Form {
                // Category selection
                Section("Category") {
                    Picker("Select Category", selection: $split.categId) {
                        if (split.categId.isVoid) {
                            Text("Category:").tag(DataId.void)
                        }
                        ForEach(vm.categoryList.evalTree.readyValue?.order ?? [], id: \.dataId) { node in
                            if let path = vm.categoryList.evalPath.readyValue?[node.dataId] {
                                Text(path).tag(node.dataId)
                            }
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Amount") {
                    TextField("Amount", value: $split.amount, format: .number)
                        .keyboardType(pref.theme.decimalPad)
                }

                Section("Notes") {
                    TextField("Notes", text: $split.notes)
                        .keyboardType(pref.theme.textPad)
                }

                if let onDelete = onDelete {
                    Section {
                        Button(role: .destructive) {
                            onDelete()
                            dismiss()
                        } label: {
                            Label("Delete Split", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(onDelete == nil ? "New Split" : "Edit Split")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSave(split)
                        dismiss()
                    }
                    .disabled(split.categId.isVoid)   // 必须选择了分类才能保存
                }
            }
        }
    }
}

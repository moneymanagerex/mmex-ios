//
//  SplitEditView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/18.
//

import SwiftUI

struct SplitEditView: View {
    @Binding var split: TransactionSplitData
    var onSave: (TransactionSplitData) -> Void
    var onDelete: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var vm: ViewModel
    @EnvironmentObject var pref: Preference

    var body: some View {
        NavigationStack {
            Form {
                // 分类选择
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

                // 金额
                Section("Amount") {
                    TextField("0.00", value: $split.amount, format: .number)
                        .keyboardType(pref.theme.decimalPad)
                }

                // 备注
                Section("Notes") {
                    TextField("Notes", text: $split.notes)
                        .keyboardType(pref.theme.textPad)
                }

                // 删除按钮（仅编辑已有 split 时出现）
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

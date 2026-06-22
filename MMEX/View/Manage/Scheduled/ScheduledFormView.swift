//
//  ScheduledFormView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/22.
//

import SwiftUI

struct ScheduledFormView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @Binding var focus: Bool
    @Binding var data: ScheduledData
    @State var edit: Bool

    @FocusState var focusState: Int?

    var body: some View {
        Group {
            Section("Transaction Details") {
                // 交易类型
                pref.theme.field.view(edit, false, "Type", editView: {
                    Picker("", selection: $data.transCode) {
                        ForEach(TransactionType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }, showView: {
                    Text(data.transCode.rawValue)
                })

                // 账户
                if let accountOrder = vm.accountList.order.readyValue,
                   let accountData = vm.accountList.data.readyValue {
                    pref.theme.field.view(edit, false, "Account", editView: {
                        Picker("", selection: $data.accountId) {
                            ForEach(accountOrder, id: \.self) { id in
                                if let account = accountData[id] {
                                    Text(account.name).tag(id)
                                }
                            }
                        }
                    }, showView: {
                        pref.theme.field.valueOrError("Required", text: accountData[data.accountId]?.name)
                    })
                }

                // To Account（仅 Transfer 时显示）
                if data.transCode == .transfer {
                    if let accountOrder = vm.accountList.order.readyValue,
                       let accountData = vm.accountList.data.readyValue {
                        pref.theme.field.view(edit, false, "To Account", editView: {
                            Picker("", selection: $data.toAccountId) {
                                ForEach(accountOrder, id: \.self) { id in
                                    if let account = accountData[id], id != data.accountId {
                                        Text(account.name).tag(id)
                                    }
                                }
                            }
                        }, showView: {
                            pref.theme.field.valueOrError("Required", text: accountData[data.toAccountId]?.name)
                        })
                    }
                } else {
                    // Payee
                    if let payeeOrder = vm.payeeList.order.readyValue,
                       let payeeData = vm.payeeList.data.readyValue {
                        pref.theme.field.view(edit, false, "Payee", editView: {
                            Picker("", selection: $data.payeeId) {
                                ForEach(payeeOrder, id: \.self) { id in
                                    if let payee = payeeData[id] {
                                        Text(payee.name).tag(id)
                                    }
                                }
                            }
                        }, showView: {
                            pref.theme.field.valueOrError("Required", text: payeeData[data.payeeId]?.name)
                        })
                    }
                }

                // 金额
                let currencyId = vm.accountList.data.readyValue?[data.accountId]?.currencyId ?? .void
                let formatter = vm.currencyList.info.readyValue?[currencyId]?.formatter
                pref.theme.field.view(edit, true, "Amount", editView: {
                    TextField("0.00", value: $data.transAmount, format: .number)
                        .focused($focusState, equals: 1)
                        .keyboardType(pref.theme.decimalPad)
                }, showView: {
                    Text(data.transAmount.formatted(by: formatter))
                })

                // To Amount（仅 Transfer 时显示）
                if data.transCode == .transfer {
                    pref.theme.field.view(edit, true, "To Amount", editView: {
                        TextField("0.00", value: $data.toTransAmount, format: .number)
                            .focused($focusState, equals: 2)
                            .keyboardType(pref.theme.decimalPad)
                    }, showView: {
                        Text(data.toTransAmount.formatted(by: formatter))
                    })
                }

                // 状态
                pref.theme.field.view(edit, false, "Status", editView: {
                    Picker("", selection: $data.status) {
                        ForEach(TransactionStatus.allCases) { status in
                            Text(status.fullName).tag(status)
                        }
                    }
                }, showView: {
                    Text(data.status.fullName)
                })
            }

            Section("Schedule") {
                // 重复类型
                pref.theme.field.view(edit, false, "Repeat", editView: {
                    Picker("", selection: $data.repeatAuto) {
                        ForEach(RepeatAuto.allCases) { auto in
                            Text(auto.name).tag(auto)
                        }
                    }
                }, showView: {
                    Text(data.repeatAuto.name)
                })

                if data.repeatAuto != .none {
                    pref.theme.field.view(edit, false, "Frequency", editView: {
                        Picker("", selection: $data.repeatType) {
                            ForEach(RepeatType.allCases) { type in
                                Text(type.name).tag(type)
                            }
                        }
                    }, showView: {
                        Text(data.repeatType.name)
                    })

                    // 重复次数（-1 表示无限）
                    pref.theme.field.view(edit, true, "Occurrences", editView: {
                        TextField("-1 = infinite", value: $data.repeatNum, format: .number)
                            .focused($focusState, equals: 3)
                            .keyboardType(.numberPad)
                    }, showView: {
                        Text(data.repeatNum == -1 ? "Infinite" : "\(data.repeatNum)")
                    })
                }

                // 下次到期日
                pref.theme.field.view(edit, true, "Next Due Date", editView: {
                    DatePicker("", selection: $data.dueDate.date, displayedComponents: [.date])
                        .labelsHidden()
                }, showView: {
                    pref.theme.field.valueOrError("Required", text: data.dueDate.string)
                })

                // 原始交易日期（参考）
                pref.theme.field.view(edit, true, "Reference Date", editView: {
                    DatePicker("", selection: $data.transDate.date, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                }, showView: {
                    pref.theme.field.valueOrHint("N/A", text: data.transDate.string)
                })
            }

            Section("Category") {
                if let categoryOrder = vm.categoryList.evalTree.readyValue?.order,
                   let categoryPath = vm.categoryList.evalPath.readyValue {
                    pref.theme.field.view(edit, false, "Category", editView: {
                        Picker("", selection: $data.categId) {
                            Text("(none)").tag(DataId.void)
                            ForEach(categoryOrder, id: \.dataId) { node in
                                Text(categoryPath[node.dataId] ?? "").tag(node.dataId)
                            }
                        }
                    }, showView: {
                        pref.theme.field.valueOrHint("(none)", text: categoryPath[data.categId])
                    })
                }

                pref.theme.field.view(edit, true, "Transaction Number", editView: {
                    TextField("N/A", text: $data.transactionNumber)
                        .focused($focusState, equals: 4)
                        .keyboardType(pref.theme.textPad)
                }, showView: {
                    pref.theme.field.valueOrHint("N/A", text: data.transactionNumber)
                })
            }

            Section("Notes") {
                pref.theme.field.notes(edit, "", $data.notes)
                    .focused($focusState, equals: 5)
                    .keyboardType(pref.theme.textPad)
            }
        }
        .keyboardState(focus: $focus, focusState: $focusState)
    }
}

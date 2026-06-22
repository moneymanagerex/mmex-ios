//
//  OverviewHeader.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/22.
//

import SwiftUI

struct OverviewHeader: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @EnvironmentObject var context: AppContext
    
    @State private var showingCustomDatePicker = false
    let formatter: CurrencyFormatter?
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                // 账户菜单
                accountMenu
                
                Spacer()
                
                // 日期标题菜单
                dateMenu
                
                Spacer()
                
                // 左右导航
                HStack(spacing: 8) {
                    Button(action: { stepDate(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { stepDate(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.headline)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // 快速预设标签
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DateRangePreset.allCases, id: \.self) { preset in
                        if preset != .custom && preset != .all {
                            Button(preset.rawValue) {
                                withAnimation {
                                    context.dateRangePreset = preset
                                }
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(context.dateRangePreset == preset ? Color.accentColor : Color.gray.opacity(0.1))
                            .foregroundColor(context.dateRangePreset == preset ? .white : .primary)
                            .clipShape(Capsule())
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            }
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingCustomDatePicker) {
            customDatePickerSheet
        }
    }
    
    // MARK: - Subviews
    
    private var accountMenu: some View {
        Menu {
            Button("All Accounts") {
                context.selectedAccountId = .void
            }
            Divider()
            if let accounts = vm.accountList.data.readyValue {
                ForEach(vm.accountList.order.readyValue ?? [], id: \.self) { id in
                    if let account = accounts[id] {
                        Button {
                            context.selectedAccountId = id
                        } label: {
                            HStack {
                                Image(systemName: account.type.symbolName)
                                    .frame(width: 20, alignment: .leading)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                                
                                Text(account.name)
                                
                                Spacer()
                                
                                if let balance = vm.accountBalances[id] {
                                    Text(balance.formatted(by: formatter))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if context.selectedAccountId == id {
                                    Image(systemName: "checkmark")
                                        .font(.caption)
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
            } else {
                HStack {
                    Text("Loading accounts...")
                    Spacer()
                    ProgressView()
                }
                .disabled(true)
            }
        } label: {
            HStack(spacing: 4) {
                if let account = vm.accountList.data.readyValue?[context.selectedAccountId] {
                    Image(systemName: account.type.symbolName)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "folder")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(accountDisplayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.08))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
            )
        }
    }
    
    private var accountDisplayName: String {
        if context.selectedAccountId.isVoid {
            return "All"
        } else if let account = vm.accountList.data.readyValue?[context.selectedAccountId] {
            return account.name
        } else {
            return "Unknown"
        }
    }
    
    private var dateMenu: some View {
        Menu {
            ForEach(DateRangePreset.allCases, id: \.self) { preset in
                if preset == .custom {
                    Button("Custom Range") {
                        showingCustomDatePicker = true
                    }
                } else {
                    Button(preset.rawValue) {
                        withAnimation {
                            context.dateRangePreset = preset
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(dateRangeDisplayString)
                    .font(.headline)
                    .fontWeight(.semibold)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var dateRangeDisplayString: String {
        switch context.dateRangePreset {
        case .today:     return "Today"
        case .thisWeek:  return "This Week"
        case .thisMonth: return DateFormatter.monthYear.string(from: Date())
        case .thisYear:  return DateFormatter.year.string(from: Date())
        case .all:       return "All Time"
        case .custom:    return "Custom"
        }
    }
    
    // MARK: - Actions
    
    private func stepDate(by offset: Int) {
        let calendar = Calendar.current
        let currentStart = context.effectiveStartDate ?? Date()
        let currentEnd = context.effectiveEndDate ?? Date()
        var newStart: Date?
        var newEnd: Date?
        
        switch context.dateRangePreset {
        case .today, .thisWeek:
            newStart = calendar.date(byAdding: .day, value: offset * 7, to: currentStart)
            newEnd = calendar.date(byAdding: .day, value: offset * 7, to: currentEnd)
        case .thisMonth:
            newStart = calendar.date(byAdding: .month, value: offset, to: currentStart)
            newEnd = calendar.date(byAdding: .month, value: offset, to: currentEnd)
        case .thisYear:
            newStart = calendar.date(byAdding: .year, value: offset, to: currentStart)
            newEnd = calendar.date(byAdding: .year, value: offset, to: currentEnd)
        default:
            return
        }
        
        guard let start = newStart, let end = newEnd else { return }
        context.dateRangePreset = .custom
        context.customStartDate = DateString(start).string
        context.customEndDate = DateString(end).string
    }
    
    // MARK: - Custom Date Picker Sheet
    
    private var customDatePickerSheet: some View {
        NavigationView {
            VStack {
                DatePicker("Start Date", selection: Binding(
                    get: { context.effectiveStartDate ?? Date() },
                    set: { context.customStartDate = DateString($0).string }
                ), displayedComponents: .date)
                DatePicker("End Dates", selection: Binding(
                    get: { context.effectiveEndDate ?? Date() },
                    set: { context.customEndDate = DateString($0).string }
                ), displayedComponents: .date)
                Spacer()
            }
            .padding()
            .navigationTitle("Custom Range")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingCustomDatePicker = false
                        context.dateRangePreset = .custom
                    }
                }
            }
        }
    }
}

// 扩展 DateFormatter
extension DateFormatter {
    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()
    
    static let year: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
}

//
//  ScheduledOverviewView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/22.
//

import SwiftUI

struct ScheduledOverviewView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @EnvironmentObject var context: AppContext

    @StateObject private var viewModel = ScheduledOverviewViewModel()
    
    @State private var toastMessage: String?
    @State private var showingToast = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            
            if viewModel.isLoading && !hasItems {
                loadingView
            } else if hasItems {
                content
            } else {
                emptyView
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .toast(isPresented: $showingToast, message: toastMessage)
        .onAppear {
            if vm.scheduledList.state != .ready {
                Task {
                    await vm.loadScheduledList(pref)
                }
            }
            let accountId = context.selectedAccountId
            viewModel.load(from: vm, accountId: accountId)
        }
        .onChange(of: vm.scheduledList.state) { _, _ in
            let accountId = context.selectedAccountId
            viewModel.load(from: vm, accountId: accountId)
        }
        .onChange(of: context.selectedAccountId) { _, _ in
            viewModel.load(from: vm, accountId: context.selectedAccountId)
        }
    }
    
    // MARK: - Subviews
    
    private var header: some View {
        HStack {
            Text("Scheduled Transactions")
                .font(.headline)
            Spacer()
            if viewModel.isLoading {
                ProgressView().scaleEffect(0.7)
            }

            // Add "View All" link
            NavigationLink("View All") {
                JournalView(initialTypeFilter: .scheduled)  // opens the journal list
            }
            .font(.caption)
            .foregroundColor(.accentColor)

            let count = viewModel.overdue.count + viewModel.dueToday.count +
                        viewModel.dueSoon.count + viewModel.upcoming.count
            if count > 0 {
                BadgeCount(count: count)
                    .padding(.leading, 4)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
    
    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView("Loading scheduled transactions...")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
    }
    
    private var emptyView: some View {
        HStack {
            Spacer()
            Text("No upcoming scheduled transactions")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
            Spacer()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        ForEach(sections, id: \.title) { section in
            if !section.items.isEmpty {
                sectionView(title: section.title, color: section.color, items: section.items)
            }
        }
    }
    
    private var sections: [(title: String, color: Color, items: [ScheduledOverviewItem])] {
        [
            ("Overdue", .red, viewModel.overdue),
            ("Due Today", .orange, viewModel.dueToday),
            ("Due Soon", .blue, viewModel.dueSoon),
            ("Upcoming", .secondary, viewModel.upcoming)
        ]
    }
    
    private func sectionView(title: String, color: Color, items: [ScheduledOverviewItem]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
                .padding(.horizontal)
            
            ForEach(items) { item in
                itemRow(item)
            }
        }
        .padding(.bottom, 4)
    }
    
    @ViewBuilder
    private func itemRow(_ item: ScheduledOverviewItem) -> some View {
        HStack(alignment: .center, spacing: 12) {
            // 图标
            let categoryName = vm.categoryList.data.readyValue?[item.scheduled.categId]?.name ?? ""
            let symbol = pref.symbol.category2symbol[categoryName] ?? "tag.fill"
            Image(systemName: symbol)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            // 主要内容
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(payeeName(for: item))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    let currencyId = vm.accountList.data.readyValue?[item.scheduled.accountId]?.currencyId ?? .void
                    let formatter = vm.currencyList.info.readyValue?[currencyId]?.formatter
                    Text(item.scheduled.transAmount.formatted(by: formatter))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(item.status == .overdue ? .red : .primary)
                }
                
                HStack {
                    Text(item.daysText)
                        .font(.caption)
                        .foregroundColor(item.status == .overdue ? .red : .secondary)
                    
                    Spacer()
                    
                    // 操作按钮
                    if item.isRecurring {
                        HStack(spacing: 8) {
                            Button("Skip") {
                                Task { await handleSkip(item) }
                            }
                            .font(.caption)
                            .buttonStyle(.borderless)
                            .foregroundColor(.gray)
                            
                            Button("Paid") {
                                Task { await handleMarkPaid(item) }
                            }
                            .font(.caption)
                            .buttonStyle(.borderedProminent)
                            .controlSize(.mini)
                            .tint(.green)
                        }
                    } else {
                        Text("One-time")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.04))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    // MARK: - Action Handlers
    
    private func handleSkip(_ item: ScheduledOverviewItem) async {
        let success = await viewModel.skip(item, in: vm)
        toastMessage = success ? "Skipped to next occurrence" : "Failed to skip"
        showingToast = true
        if success { refresh() }
    }
    
    private func handleMarkPaid(_ item: ScheduledOverviewItem) async {
        let success = await viewModel.markAsPaid(item, in: vm)
        toastMessage = success ? "Transaction created ✓" : "Failed to mark as paid"
        showingToast = true
        if success { refresh() }
    }
    
    private func refresh() {
        Task {
            vm.unloadList(ScheduledList.self)
            await vm.loadScheduledList(pref)
            let accountId = context.selectedAccountId
            viewModel.load(from: vm, accountId: accountId)
            vm.objectWillChange.send()
        }
    }
    
    // MARK: - Helpers
    
    private var hasItems: Bool {
        viewModel.overdue.count + viewModel.dueToday.count +
        viewModel.dueSoon.count + viewModel.upcoming.count > 0
    }
    
    private func payeeName(for item: ScheduledOverviewItem) -> String {
        if item.scheduled.transCode == .transfer {
            return vm.accountList.data.readyValue?[item.scheduled.toAccountId]?.name ?? "Transfer"
        } else {
            return vm.payeeList.data.readyValue?[item.scheduled.payeeId]?.name ?? "(unknown)"
        }
    }
}

extension View {
    func toast(isPresented: Binding<Bool>, message: String?) -> some View {
        self.modifier(ToastModifier(isPresented: isPresented, message: message))
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String?
    @State private var timer: Timer?
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isPresented, let message {
                    Text(message)
                        .font(.subheadline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                                withAnimation { isPresented = false }
                            }
                        }
                        .onDisappear {
                            timer?.invalidate()
                            timer = nil
                        }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isPresented)
    }
}

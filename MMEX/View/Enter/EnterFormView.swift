//
//  EnterFormView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/10.
//

import SwiftUI

struct EnterFormView: View {
    @EnvironmentObject var pref: Preference
    @EnvironmentObject var vm: ViewModel
    @Binding var focus: Bool
    @Binding var journal: JournalData

    @FocusState var focusState: Int?

    @State private var editSplitData = JournalSplitData()
    @State private var editingSplitIndex: Int? = nil
    @State private var showingSplitEditor = false

    @State private var accountCreation: AccountCreation?
    @State private var payeeCreation: PayeeData?
    @State private var showingCreateCategory = false

    @State private var createCategoryData = CategoryListView.initData

    @State private var newAccountData: AccountData? = nil
    @State private var newPayeeData: PayeeData? = nil
    @State private var newCategoryData: CategoryData? = nil
    @State private var selector: EntrySelector?
    @State private var createAfterSelector: EntrySelector?

    private enum EntrySelector: String, Identifiable {
        case account, toAccount, payee, category
        var id: String { rawValue }
    }

    private struct AccountCreation: Identifiable {
        let id = UUID()
        let data: AccountData
        let forDestination: Bool
    }

    private var suggestedCategory: (DataId, String)? {
        guard journal.transCode != .transfer, journal.categId.isVoid, journal.splits.isEmpty,
              let payee = vm.payeeList.data.readyValue?[journal.payeeId],
              !payee.categoryId.isVoid,
              let path = vm.categoryList.evalPath.readyValue?[payee.categoryId] else { return nil }
        return (payee.categoryId, path)
    }

    var body: some View {
        VStack {
            // 0. (Transaction / Scheduled）
            Picker("Type", selection: $journal.type) {
                Text("Transaction").tag(JournalType.transaction)
                Text("Scheduled").tag(JournalType.scheduled)
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 4)
            .disabled(!journal.id.isVoid)
            
            // 1. Transaction type picker (Deposit/Withdrawal/Transfer)
            HStack {
                Picker("", selection: $journal.transCode) {
                    ForEach(TransactionType.allCases) { transCode in
                        Text(transCode.name).tag(transCode)
                    }
                }
                .padding(0)
                // do not use segmented style, in order to avoid truncation in smaller displays
                //.pickerStyle(SegmentedPickerStyle())

                Spacer()

                HStack(spacing: 6) {
                    Button {
                        selector = .account
                    } label: {
                        Text(vm.accountList.data.readyValue?[journal.accountId]?.name ?? String(localized: "Choose account"))
                    }
                    .accessibilityLabel("Select account")
                    .accessibilityValue(vm.accountList.data.readyValue?[journal.accountId]?.name ?? String(localized: "Choose account"))
                }
            }
            .padding(.horizontal, 0)

            // 2. Unified Numeric Input for the Amount with automatic keyboard focus
            TextField("", value: $journal.transAmount, format: .number)
                .focused($focusState, equals: 1)
                .keyboardType(pref.theme.decimalPad) // Show numeric keyboard with decimal support
                .font(.system(size: 48, weight: .bold)) // Large, bold text for amount input
                .multilineTextAlignment(.center) // Center the text for better UX
                .padding()
                .background(Color.gray.opacity(0.2)) // Background styling for the input field
                .foregroundColor(!journal.splits.isEmpty ? .gray : .primary)
                .cornerRadius(10) // Rounded corners
                .padding(.bottom, 0) // Space between the amount input and the next section
                .disabled(!journal.splits.isEmpty)
                .onChange(of: journal.transAmount) {
                    journal.toTransAmount = journal.transAmount
                }
            
            // 3. Input field for notes
            TextField("Add Note", text: Binding(
                get: { journal.notes }, // Safely unwrap the optional notes field
                set: { journal.notes = $0 } // Set notes to nil if the input is empty
            ))
            .focused($focusState, equals: 2)
            .keyboardType(pref.theme.textPad)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.2)) // Style the notes input field
            .cornerRadius(10)
            .padding(.top, 0)
            
            // 4. Horizontal stack for date picker and status picker
            HStack {
                // Date Picker to select transaction date and time
                DatePicker("Date", selection: $journal.transDate.date, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden() // Hide the default label to save space
                    .onChange(of: journal.transDate.date) { _, newDate in
                    }
                Menu {
                    Button("Today") { setEntryDate(Date()) }
                    Button("Yesterday") {
                        if let date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
                            setEntryDate(date)
                        }
                    }
                } label: {
                    Image(systemName: "calendar.badge.clock")
                }
                .accessibilityLabel("Quick date")
                
                Spacer()
                
                // Transaction status picker
                Menu(content: {
                    Picker("Transaction Status", selection: $journal.status) {
                        ForEach(TransactionStatus.allCases) { status in
                            Text(status.fullName).tag(status)
                        }
                    }
                }, label: { (
                    Text("\(journal.status.shortName) ") +
                    Text(Image(systemName: "chevron.up.chevron.down"))
                ) } )

            }
            .padding(.horizontal, 0)

            // 5. Horizontal stack for Payee and Category pickers
            HStack {
                if journal.transCode == .transfer {
                    Button {
                        selector = .toAccount
                    } label: {
                        Text(vm.accountList.data.readyValue?[journal.toAccountId]?.name ?? String(localized: "Choose destination account"))
                    }
                    .accessibilityLabel("Select To Account")
                    .accessibilityValue(vm.accountList.data.readyValue?[journal.toAccountId]?.name ?? String(localized: "Choose destination account"))
                } else {
                    Button {
                        selector = .payee
                    } label: {
                        Text(vm.payeeList.data.readyValue?[journal.payeeId]?.name ?? String(localized: "Choose payee"))
                    }
                    .accessibilityLabel("Select Payee")
                    .accessibilityValue(vm.payeeList.data.readyValue?[journal.payeeId]?.name ?? String(localized: "Choose payee"))
                }
                Spacer()

                Button {
                    selector = .category
                } label: {
                    Text(vm.categoryList.evalPath.readyValue?[journal.categId] ?? String(localized: "Choose category"))
                        .lineLimit(1)
                }
                .accessibilityLabel("Select Category")
                .accessibilityValue(vm.categoryList.evalPath.readyValue?[journal.categId] ?? String(localized: "Choose category"))
                .disabled(!journal.splits.isEmpty)
            }
            .padding(.horizontal, 0)

            validationHint

            if let categories = vm.categoryList.data.readyValue,
               categories.isEmpty, journal.splits.isEmpty, journal.categId.isVoid {
                Button {
                    prepareCreateCategory()
                } label: {
                    Label("Add your first category", systemImage: "plus.circle")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if vm.categoryList.evalTree.readyValue != nil {
                categoryHint
            }

            if let (id, name) = suggestedCategory {
                Button {
                    journal.categId = id
                } label: {
                    Text("Suggested category: \(name)")
                        .font(.footnote)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            if journal.transCode != .transfer, vm.payeeList.order.readyValue?.isEmpty == true {
                Button {
                    prepareCreatePayee()
                } label: {
                    Label("Add your first payee", systemImage: "plus.circle")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // 6.
            if journal.type == .scheduled {
                Group {
                    Divider()
                    Text("Recurring Settings").font(.headline)
                    HStack {
                        Picker("Repeat", selection: $journal.repeatAuto) {
                            ForEach(RepeatAuto.allCases) { auto in
                                Text(auto.name).tag(auto)
                            }
                        }
                        Spacer()
                        if journal.repeatAuto != .none {
                            Picker("Frequency", selection: $journal.repeatType) {
                                ForEach(RepeatType.allCases) { type in
                                    Text(type.name).tag(type)
                                }
                            }
                        }
                    }
                    if journal.repeatAuto != .none {
                        HStack {
                            Text("Occurrences")
                            Spacer()
                            HStack(spacing: 4) {
                                TextField("", value: $journal.repeatNum, format: .number)
                                    .frame(width: 50)
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.numberPad)
                                    .disabled(journal.repeatNum == -1)  // 无限时不可编辑

                                Text(journal.repeatNum == -1 ? "∞" : "times")
                                    .foregroundColor(journal.repeatNum == -1 ? .accentColor : .secondary)
                                    .onTapGesture {
                                        // 切换无限模式
                                        if journal.repeatNum == -1 {
                                            journal.repeatNum = 1
                                        } else {
                                            journal.repeatNum = -1
                                        }
                                    }
                            }
                        }
                    }
                    DatePicker("Next Due Date", selection: $journal.dueDate.date, displayedComponents: [.date])
                        .onChange(of: journal.dueDate.date) { _, newDate in
                            journal.transDate.date = newDate
                        }
                }
            }
            
            // 7. Splits Section
            if journal.transCode != .transfer {
                Form {
                    Section(header: Text("Splits")) {
                        HStack {
                            Text("Category")
                                .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                            Text("Amount")
                                .frame(width: 60, alignment: .center) // Centered with fixed width
                            Text("Notes")
                                .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
                        }
                        .padding(.horizontal, 0)

                        ForEach(journal.splits.indices, id: \.self) { index in
                            let split = journal.splits[index]
                            Button {
                                editSplitData = split          // 复制当前值
                                editingSplitIndex = index
                                showingSplitEditor = true      // 显示 sheet
                            } label: {
                                HStack {
                                    Text(vm.categoryList.evalPath.readyValue?[split.categId] ?? "")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.primary)
                                    Text(split.amount.formatted(
                                        by: vm.currencyList.info.readyValue?[
                                            vm.accountList.data.readyValue?[journal.accountId]?.currencyId ?? .void
                                        ]?.formatter
                                    ))
                                    .frame(width: 60, alignment: .center)
                                    Text(split.notes)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .contentShape(Rectangle())      // 扩大点击区域
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { indices in
                            journal.splits.remove(atOffsets: indices)
                            journal.transAmount = journal.splits.reduce(0.0) { $0 + $1.amount }
                        }

                        Button {
                            editSplitData = JournalSplitData()
                            editingSplitIndex = nil
                            showingSplitEditor = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .disabled(!journal.categId.isVoid)
                        .accessibilityLabel("Add split")   // 保证 VoiceOver 可用
                    }
                    .listRowInsets(EdgeInsets())
                }
                .padding(.vertical, 0)
            }

            Spacer() // Push the contents to the top
        }
        .keyboardState(focus: $focus, focusState: $focusState)
        .padding(.horizontal)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        prepareCreateAccount()
                    } label: {
                        Label("Create Account", systemImage: "plus")
                    }

                    Button {
                        prepareCreatePayee()
                    } label: {
                        Label("Create Payee", systemImage: "plus")
                    }

                    Button {
                        prepareCreateCategory()
                    } label: {
                        Label("Create Category", systemImage: "plus")
                    }
                    .disabled(!journal.splits.isEmpty)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("More create actions")
            }
        }

        .onAppear {
            // Initialize state variables from the journal object when the view appears
            Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                focusState = 1
            }
        }
        .onDisappear {
            focusState = nil
        }
        .sheet(item: $selector, onDismiss: {
            guard let next = createAfterSelector else { return }
            createAfterSelector = nil
            switch next {
            case .account: prepareCreateAccount()
            case .toAccount: prepareCreateAccount(forDestination: true)
            case .payee: prepareCreatePayee()
            case .category: prepareCreateCategory()
            }
        }) { kind in
            EntrySelectionView(
                title: selectorTitle(kind),
                createTitle: createTitle(kind),
                choices: choices(for: kind),
                recentIds: recentIds(for: kind),
                selected: selectedId(kind),
                onSelect: { id in
                    switch kind {
                    case .account: journal.accountId = id
                    case .toAccount: journal.toAccountId = id
                    case .payee: journal.payeeId = id
                    case .category: journal.categId = id
                    }
                    selector = nil
                },
                onCreate: {
                    createAfterSelector = kind
                    selector = nil
                }
            )
        }
        .sheet(item: $accountCreation) { creation in
            NavigationView {
                RepositoryCreateView(
                    isPresented: Binding(
                        get: { accountCreation != nil },
                        set: { if !$0 { accountCreation = nil } }
                    ),
                    features: AccountListView.features,
                    data: creation.data,
                    newData: $newAccountData,
                    formView: { focus, data, edit in
                        AccountFormView(focus: focus, data: data, edit: edit)
                    }
                )
                .navigationBarTitle("Create Account", displayMode: .inline)
            }
            .onDisappear {
                guard let created = newAccountData else { return }
                Task { @MainActor in
                    await vm.reloadAccount(pref, nil as AccountData?, created)
                    if creation.forDestination {
                        journal.toAccountId = created.id
                    } else {
                        journal.accountId = created.id
                    }
                    newAccountData = nil
                }
            }
        }
        .sheet(item: $payeeCreation) { data in
            NavigationView {
                RepositoryCreateView(
                    isPresented: Binding(
                        get: { payeeCreation != nil },
                        set: { if !$0 { payeeCreation = nil } }
                    ),
                    features: PayeeListView.features,
                    data: data,
                    newData: $newPayeeData,
                    formView: { focus, data, edit in
                        PayeeFormView(focus: focus, data: data, edit: edit)
                    }
                )
                .navigationBarTitle("Create Payee", displayMode: .inline)
            }
            .onDisappear {
                guard let created = newPayeeData else { return }
                Task { @MainActor in
                    await vm.reloadPayee(pref, nil as PayeeData?, created)
                    journal.payeeId = created.id
                    newPayeeData = nil
                }
            }
        }
        .sheet(isPresented: $showingCreateCategory) {
            NavigationView {
                RepositoryCreateView(
                    isPresented: $showingCreateCategory,
                    features: CategoryListView.features,
                    data: createCategoryData,
                    newData: $newCategoryData,
                    formView: { focus, data, edit in
                        CategoryFormView(focus: focus, data: data, edit: edit)
                    }
                )
                .navigationBarTitle("Create Category", displayMode: .inline)
            }
            .onDisappear {
                guard let created = newCategoryData else { return }
                Task { @MainActor in
                    await vm.reloadCategory(pref, nil as CategoryData?, created)
                    journal.categId = created.id
                    newCategoryData = nil
                }
            }
        }
        .sheet(isPresented: $showingSplitEditor) {
            SplitEditView(
                split: $editSplitData,
                onSave: { updatedSplit in
                    if let idx = editingSplitIndex {
                        journal.splits[idx] = updatedSplit
                    } else {
                        journal.splits.append(updatedSplit)
                    }
                    journal.transAmount = journal.splits.reduce(0.0) { $0 + $1.amount }
                    // dismiss 会在 SplitEditView 内部调用，这里不需要
                },
                onDelete: editingSplitIndex != nil ? {
                    if let idx = editingSplitIndex {
                        journal.splits.remove(at: idx)
                        journal.transAmount = journal.splits.reduce(0.0) { $0 + $1.amount }
                    }
                } : nil
            )
        }
    }

    @ViewBuilder
    private var validationHint: some View {
        if journal.accountId.isVoid {
            Button("Choose an account to continue.") { selector = .account }
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else if journal.transCode == .transfer,
                  journal.toAccountId.isVoid || journal.toAccountId == journal.accountId {
            Button("Choose a different destination account.") { selector = .toAccount }
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else if journal.transCode != .transfer, journal.payeeId.isVoid {
            Button("Choose a payee to continue.") { selector = .payee }
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else if !(journal.transAmount >= 0) {
            hint("Enter an amount of zero or more.")
        }
    }

    @ViewBuilder
    private var categoryHint: some View {
        switch journal.categoryIssue {
        case .missingCategory:
            if journal.transCode == .transfer {
                hint("Choose a category to continue.")
            } else {
                hint("Choose a category or add splits to continue.")
            }
        case .tooFewSplits:
            hint("Add at least two splits to continue.")
        case .splitAmountMismatch:
            hint("Split amounts must match the transaction amount.")
        case .categoryAndSplits:
            hint("Remove the splits to use the selected category.")
        case nil:
            EmptyView()
        }
    }

    private func hint(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private func prepareCreateAccount(forDestination: Bool = false) {
        var data = AccountListView.initData
        data.currencyId = vm.accountList.data.readyValue?[journal.accountId]?.currencyId
            ?? vm.accountList.order.readyValue?.first.flatMap { vm.accountList.data.readyValue?[$0]?.currencyId }
            ?? .void
        accountCreation = AccountCreation(data: data, forDestination: forDestination)
    }

    private func prepareCreatePayee() {
        var data = PayeeListView.initData
        if !journal.categId.isVoid {
            data.categoryId = journal.categId
        }
        payeeCreation = data
    }

    private func prepareCreateCategory() {
        createCategoryData = CategoryListView.initData
        showingCreateCategory = true
    }

    private func setEntryDate(_ date: Date) {
        journal.transDate.date = date
        if journal.type == .scheduled { journal.dueDate.date = date }
    }

    private func choices(for kind: EntrySelector) -> [EntryChoice] {
        switch kind {
        case .account, .toAccount:
            return (vm.accountList.order.readyValue ?? []).compactMap { id in
                guard kind != .toAccount || id != journal.accountId else { return nil }
                return vm.accountList.data.readyValue?[id].map { EntryChoice(id: id, name: $0.name) }
            }
        case .payee:
            return (vm.payeeList.order.readyValue ?? []).compactMap { id in
                vm.payeeList.data.readyValue?[id].map { EntryChoice(id: id, name: $0.name) }
            }
        case .category:
            return (vm.categoryList.evalTree.readyValue?.order ?? []).compactMap { node in
                vm.categoryList.evalPath.readyValue?[node.dataId].map { EntryChoice(id: node.dataId, name: $0) }
            }
        }
    }

    private func recentIds(for kind: EntrySelector) -> [DataId] {
        guard let repository = TransactionRepository(vm.db) else { return [] }
        guard let transactions = repository.recentForEntry() else { return [] }
        var seen = Set<DataId>()
        return transactions.compactMap { transaction in
            let id: DataId
            switch kind {
            case .account: id = transaction.accountId
            case .toAccount: id = transaction.toAccountId
            case .payee: id = transaction.payeeId
            case .category: id = transaction.categId
            }
            return !id.isVoid && seen.insert(id).inserted ? id : nil
        }.prefix(5).map { $0 }
    }

    private func selectorTitle(_ kind: EntrySelector) -> LocalizedStringKey {
        switch kind {
        case .account: "Select account"
        case .toAccount: "Select To Account"
        case .payee: "Select Payee"
        case .category: "Select Category"
        }
    }

    private func createTitle(_ kind: EntrySelector) -> LocalizedStringKey {
        switch kind {
        case .account, .toAccount: "Create Account"
        case .payee: "Create Payee"
        case .category: "Create Category"
        }
    }

    private func selectedId(_ kind: EntrySelector) -> DataId {
        switch kind {
        case .account: journal.accountId
        case .toAccount: journal.toAccountId
        case .payee: journal.payeeId
        case .category: journal.categId
        }
    }
}

private struct EntryChoice: Identifiable {
    let id: DataId
    let name: String
}

private struct EntrySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    let title: LocalizedStringKey
    let createTitle: LocalizedStringKey
    let choices: [EntryChoice]
    let recentIds: [DataId]
    let selected: DataId
    let onSelect: (DataId) -> Void
    let onCreate: () -> Void
    @State private var search = ""

    private var filtered: [EntryChoice] {
        search.isEmpty ? choices : choices.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        NavigationStack {
            List {
                if search.isEmpty {
                    let recent = recentIds.compactMap { id in choices.first { $0.id == id } }
                    if !recent.isEmpty {
                        Section("Recent") {
                            ForEach(recent) { choice in choiceButton(choice) }
                        }
                    }
                }
                Section("All") {
                    ForEach(filtered) { choice in choiceButton(choice) }
                }
            }
            .searchable(text: $search, prompt: "Search by keyword")
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: onCreate) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(createTitle)
                }
            }
        }
    }

    private func choiceButton(_ choice: EntryChoice) -> some View {
        Button {
            onSelect(choice.id)
        } label: {
            HStack {
                Text(choice.name).foregroundStyle(.primary)
                Spacer()
                if choice.id == selected { Image(systemName: "checkmark") }
            }
        }
    }
}

#Preview("[0]") {
    MMEXPreview.enter(
        TransactionData.sampleData[0]
    )
}

#Preview("[3]") {
    MMEXPreview.enter(
        TransactionData.sampleData[3]
    )
}

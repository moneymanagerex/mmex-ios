//
//  RpositoryListView.swift
//  MMEX
//
//  2024-10-09: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

protocol RepositoryPartitionProtocol: EnumCollateNoCase, Hashable
where Self.AllCases: RandomAccessCollection {
}

struct RepositoryGroup {
    var dataId     : [Int64] = []
    var isVisible  : Bool = true
    var isExpanded : Bool = true
}

protocol RepositoryViewModelProtocol: ObservableObject {
    associatedtype RepositoryData      : DataProtocol
    associatedtype RepositoryPartition : RepositoryPartitionProtocol

    var env       : EnvironmentManager { get }
    var dataById  : [Int64: RepositoryData]? { get }
    var group     : [RepositoryGroup]? { get set }
    var partition : RepositoryPartition { get set }
    var search    : String { get set }

    static var newData: RepositoryData { get }

    init(env: EnvironmentManager)

    var dataIsReady: Bool { get }
    var groupIsReady: Bool { get }

    func loadData()
    func loadGroup()
    func isVisible(data: RepositoryData) -> Bool
}

extension RepositoryViewModelProtocol {
    var dataIsReady: Bool { dataById != nil }
    var groupIsReady: Bool { group != nil }

    func id(ofGroup g: Int) -> [Int64] {
        self.group![g].dataId
    }
    
    func isVisible(group g: Int) -> Bool {
        self.group![g].isVisible
    }
    
    func isExpanded(group g: Int) -> Bool {
        self.group![g].isExpanded
    }
    
    func isVisible(dataId: Int64) -> Bool {
        isVisible(data: self.dataById![dataId]!)
    }
    
    func newPartition(_ partition: RepositoryPartition) {
        self.partition = partition
        loadGroup()
    }
    
    func filterGroup() {
        guard let dataById else { return }
        guard var group else { return }
        for g in 0..<group.count {
            let matched = search.isEmpty || group[g].dataId.first(
                where: { isVisible(dataId: $0) }
            ) != nil
            group[g].isVisible = matched
            if matched { group[g].isExpanded = true }
        }
    }

    func newSearch(_ search: String) {
        self.search = search
        filterGroup()
    }
}

struct RepositoryListView<
    RepositoryData, RepositoryPartition, RepositoryViewModel : RepositoryViewModelProtocol,
    GroupNameView: View, ItemNameView: View
>: View
where RepositoryViewModel.RepositoryData == RepositoryData,
      RepositoryViewModel.RepositoryPartition == RepositoryPartition
{
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var viewModel: RepositoryViewModel

    @State var isPresentingAddView = false
    @State var newData = RepositoryViewModel.newData

    let groupName: (_ g: Int) -> GroupNameView
    let itemName: (_ data: RepositoryData) -> ItemNameView

    init(
        env: EnvironmentManager,
        @ViewBuilder groupName: @escaping (_ g: Int) -> GroupNameView,
        @ViewBuilder itemName: @escaping (_ data: RepositoryData) -> ItemNameView
    ) {
        self.viewModel = RepositoryViewModel(env: env)
        self.groupName = groupName
        self.itemName  = itemName
    }
    
    var body: some View {
        Group {
            List {
                if let dataById = viewModel.dataById {
                    VStack {
                        HStack {
                            Spacer()
                            Picker("", selection: $viewModel.partition) {
                                ForEach(RepositoryPartition.allCases, id: \.self) { p in
                                    Text("by \(p.rawValue)").tag(p)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        if var group = viewModel.group {
                            ForEach(0..<group.count, id: \.self) { g in
                                //Group {
                                    if group[g].isVisible {
                                        groupView(g)
                                    }
                                //}
                            }
                        } else {
                            Text("Loading data ...")
                        }
                    }
                } else {
                    Text("Loading data ...")
                }
            }
            .toolbar {
                Button(
                    action: { isPresentingAddView = true },
                    label: { Image(systemName: "plus") }
                )
                .accessibilityLabel("New Account")
            }
            .searchable(text: $viewModel.search, prompt: "Search by name")
            .textInputAutocapitalization(.never)
            .onChange(of: viewModel.search) { _, newValue in
                viewModel.filterGroup()
            }
        }
        .navigationTitle("Accounts")
        .onAppear {
            //viewModel.env = env
            viewModel.loadData()
            //loadCurrencyName()
            //loadDataById()
            //partition.load()
            //loadAccountData()
        }
        .sheet(isPresented: $isPresentingAddView) {
/*
            AccountAddView(
                allCurrencyName: $allCurrencyName,
                newAccount: $newAccount,
                isPresentingAddView: $isPresentingAddView
            ) { newAccount in
                addAccount(account: &newAccount)
                newAccount = RepositoryViewModel.newData
            }
 */
        }
    }

    func groupView(_ g: Int) -> some View {
        Section(header: HStack {
            Button(action: {
                viewModel.group![g].isExpanded.toggle()
            }) {
                env.theme.group.hstack(
                    viewModel.group![g].isExpanded
                ) {
                    groupName(g)
                }
            }
        }
        ) {
            if viewModel.group![g].isExpanded {
                ForEach(viewModel.group![g].dataId, id: \.self) { id in
                    // TODO: update View after change in account
                    if viewModel.isVisible(dataId: id) {
                        itemView(viewModel.dataById![id]!)
                    }
                }
            }
        }
    }

    func itemView(_ data: RepositoryData) -> some View {
/*
        NavigationLink(destination: AccountDetailView(
            allCurrencyName: $allCurrencyName,
            account: account
        ) ) {
            HStack {
 */
                itemName(data)
        /*
                    .font(.subheadline)
                
                Spacer()
                
                if let currency = env.currencyCache[account.currencyId] {
                    Text(currency.name)
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)
        }
 */
    }

/*
    // Initialize the expanded state for each account type
    private func initializeType() {
        for accountType in allAccountDataByType.keys {
            isTypeVisible[accountType] = true
            isTypeExpanded[accountType] = true // Default to expanded
        }
    }
 */

    /*

    func loadAccountData() {
        let repository = env.accountRepository
        DispatchQueue.global(qos: .background).async {
            typealias A = AccountRepository
            let dataByType = repository?.loadByType(
                from: A.table.order(A.col_name)
            ) ?? [:]
            DispatchQueue.main.async {
                self.allAccountDataByType = dataByType
                self.initializeType()
            }
        }
    }
     */

    func addAccount(account: inout AccountData) {
        guard let repository = env.accountRepository else { return }
        if repository.insert(&account) {
            // self.accounts.append(account)
            if env.currencyCache[account.currencyId] == nil {
                env.loadCurrency()
            }
            env.accountCache.update(id: account.id, data: account)
            //self.loadAccountData()
        }
    }
}

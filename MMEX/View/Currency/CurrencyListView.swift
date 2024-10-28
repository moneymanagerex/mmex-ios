//
//  CurrencyListView.swift
//  MMEX
//
//  2024-09-17: Created by Lisheng Guan
//  2024-10-28: Edited by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct CurrencyListView: View {
    typealias MainData = CurrencyData
    @EnvironmentObject var env: EnvironmentManager
    @ObservedObject var vm: ViewModel

    @State var search: CurrencySearch = .init()

    static let initData = CurrencyData(
        decimalPoint   : ".",
        groupSeparator : ",",
        scale          : 100,
        baseConvRate   : 1.0
    )

    var body: some View {
        RepositoryListView(
            vm: vm,
            vmList: vm.currencyList,
            groupChoice: vm.currencyGroup.choice,
            vmGroup: $vm.currencyGroup,
            search: $search,
            initData: Self.initData,
            groupName: groupName,
            itemName: itemName,
            itemInfo: itemInfo,
            editView: editView
        )
        .onAppear {
            let _ = log.debug("DEBUG: CurrencyListView.onAppear()")
        }
    }
    
    func groupName(_ g: Int, _ name: String?) -> some View {
        Text(name ?? "(unknown group name)")
    }
    
    func itemName(_ data: CurrencyData) -> some View {
        Text(data.name)
    }
    
    func itemInfo(_ data: CurrencyData) -> some View {
        Text(data.symbol)
    }

    func editView(_ data: Binding<MainData>, _ edit: Bool) -> some View {
        CurrencyEditView(
            vm: vm,
            data: data,
            edit: edit
        )
    }
}

#Preview {
    let env = EnvironmentManager.sampleData
    CurrencyListView(
        vm: ViewModel(env: env)
    )
    .environmentObject(env)
}

/*
struct OldCurrencyListView: View {
    @EnvironmentObject var env: EnvironmentManager // Access EnvironmentManager

    @State private var allCurrencyData: [CurrencyData] = [] // sorted by name
    @State private var isExpanded: [Bool : Bool] = [true: true, false: false]
    @State private var isPresentingAddView = false
    @State private var newCurrency = emptyCurrency

    static let emptyCurrency = CurrencyData(
        decimalPoint   : ".",
        groupSeparator : ",",
        scale          : 100,
        baseConvRate   : 1.0
    )

    var body: some View {
        Group {
            List { ForEach([true, false], id: \.self) { inUse in
                Section(header: HStack {
                    Button(action: {
                        isExpanded[inUse]?.toggle()
                    }) {
                        env.theme.group.view(
                            name: { Text(inUse ? "Used" : "Not Used") },
                            isExpanded: isExpanded[inUse] == true
                        )
                    }
                }) {
                    if isExpanded[inUse] == true {
                        ForEach($allCurrencyData) { $currency in
                            if (env.currencyCache[currency.id] != nil) == inUse {
                                NavigationLink(destination: CurrencyDetailView(
                                    currency: $currency
                                ) ) { HStack {
                                    Text(currency.name)
                                    Spacer()
                                    Text(currency.symbol)
                                } }
                            }
                        }
                    }
                }//.listSectionSpacing(10)
                //Text("end")
            } }
            .toolbar {
                Button(action: {
                    isPresentingAddView = true
                }, label: {
                    Image(systemName: "plus")
                })
            }
        }
        .navigationTitle("Currencies")
        .onAppear {
            loadCurrencyData()
        }
        .sheet(isPresented: $isPresentingAddView) {
            CurrencyAddView(
                newCurrency: $newCurrency,
                isPresentingAddView: $isPresentingAddView
            ) { currency in
                addCurrency(&currency)
                newCurrency = Self.emptyCurrency
            }
        }
    }

    func loadCurrencyData() {
        let repository = CurrencyRepository(env)
        DispatchQueue.global(qos: .background).async {
            let data = repository?.load() ?? []
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.allCurrencyData = data
            }
        }
    }

    func addCurrency(_ currency: inout CurrencyData) {
        guard let repository = CurrencyRepository(env) else { return }
        if repository.insert(&currency) {
            self.loadCurrencyData()
        } else {
            // TODO
        }
    }
}

#Preview {
    OldCurrencyListView(
    )
    .environmentObject(EnvironmentManager.sampleData)
}
*/

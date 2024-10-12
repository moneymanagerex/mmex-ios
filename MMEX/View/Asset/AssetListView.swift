//
//  AssetListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/25.
//

import SwiftUI

struct AssetListView: View {
    @EnvironmentObject var env: EnvironmentManager

    @State private var allCurrencyName: [(DataId, String)] = [] // sorted by name
    @State private var allAssetDataByType: [AssetType: [AssetData]] = [:] // sorted by name
    @State private var isTypeVisible:  [AssetType: Bool] = [:]
    @State private var isTypeExpanded: [AssetType: Bool] = [:]
    @State private var search: String = ""
    @State private var isPresentingAddView = false
    @State private var newAsset = emptyAsset

    static let emptyAsset = AssetData(
        status: AssetStatus.open
    )

    var body: some View {
        Group {
            List {
                ForEach(AssetType.allCases, id: \.self) { assetType in
                    if isTypeVisible[assetType] == true {
                        Section(
                            header: HStack {
                                Button(action: {
                                    isTypeExpanded[assetType]?.toggle()
                                }) {
                                    env.theme.group.view(
                                        isTypeExpanded[assetType] == true
                                    ) {
                                        Text(assetType.rawValue)
                                    }
                                }
                            }
                        ) {
                            // Show asset list based on expanded state
                            if isTypeExpanded[assetType] == true,
                               let assets = allAssetDataByType[assetType]
                            {
                                ForEach(assets) { asset in
                                    // TODO: update View after change in asset
                                    if search.isEmpty || match(asset, search) {
                                        itemView(asset)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .toolbar {
                Button(
                    action: { isPresentingAddView = true },
                    label: { Image(systemName: "plus") }
                )
                .accessibilityLabel("New Asset")
            }
            .searchable(text: $search, prompt: "Search by name")
            .textInputAutocapitalization(.never)
            .onChange(of: search) { _, value in
                filterType(by: value)
            }
        }
        .navigationTitle("Assets")
        .onAppear {
            loadCurrencyName()
            loadAssetData()
        }
        .sheet(isPresented: $isPresentingAddView) {
            AssetAddView(
                allCurrencyName: $allCurrencyName,
                newAsset: $newAsset,
                isPresentingAddView: $isPresentingAddView
            ) { newAsset in
                addAsset(asset: &newAsset)
                newAsset = Self.emptyAsset
            }
        }
    }

    func itemView(_ asset: AssetData) -> some View {
        NavigationLink(destination: AssetDetailView(
            allCurrencyName: $allCurrencyName,
            asset: asset
        ) ) {
            HStack {
                Text(asset.name)
                    .font(.subheadline)
                
                Spacer()
                
                if let formatter = env.currencyCache[asset.currencyId]?.formatter
                {
                    Text(asset.value.formatted(by: formatter))
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)
        }
    }

    // Initialize the expanded state for each account type
    private func initializeType() {
        for assetType in allAssetDataByType.keys {
            isTypeVisible[assetType] = true
            isTypeExpanded[assetType] = true // Default to expanded
        }
    }

    func filterType(by search: String) {
        for assetType in allAssetDataByType.keys {
            let matched = search.isEmpty || allAssetDataByType[assetType]?.first(where: { match($0, search) }) != nil
            isTypeVisible[assetType] = matched
            if matched { isTypeExpanded[assetType] = true }
        }
    }

    func match(_ asset: AssetData, _ search: String) -> Bool {
        asset.name.localizedCaseInsensitiveContains(search)
    }

    func loadCurrencyName() {
        let repo = env.currencyRepository
        DispatchQueue.global(qos: .background).async {
            let id_name = repo?.loadName() ?? []
            DispatchQueue.main.async {
                self.allCurrencyName = id_name
            }
        }
    }

    func loadAssetData() {
        let repository = env.assetRepository
        DispatchQueue.global(qos: .background).async {
            typealias E = AssetRepository
            let dataByType = repository?.loadByType(
                from: E.table.order(E.col_name)
            ) ?? [:]
            DispatchQueue.main.async {
                self.allAssetDataByType = dataByType
                self.initializeType()
            }
        }
    }

    func addAsset(asset: inout AssetData) {
        guard let repository = env.assetRepository else { return }
        if repository.insert(&asset) {
            if env.currencyCache[asset.currencyId] == nil {
                env.loadCurrency()
            }
            self.loadAssetData()
        }
    }
}

#Preview {
    AssetListView(
    )
    .environmentObject(EnvironmentManager.sampleData)
}

//
//  AssetListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/25.
//

import SwiftUI

struct AssetListView: View {
    let databaseURL: URL
    @State private var assets: [AssetData] = []
    @State private var filteredAssets: [AssetData] = [] // New: Filtered assets for search results
    @State private var newAsset = AssetData()
    @State private var isPresentingAssetAddView = false
    @State private var searchQuery: String = "" // New: Search query

    // Initialize repository with the databaseURL
    private var repository: AssetRepository

    init(databaseURL: URL) {
        self.databaseURL = databaseURL
        self.repository = DataManager(databaseURL: databaseURL).getAssetRepository() // pass URL here
    }

    var body: some View {
        NavigationStack {
            List($filteredAssets) { $asset in // Use filteredAssets instead of assets
                NavigationLink(destination: AssetDetailView(asset: $asset, databaseURL: databaseURL)) {
                    HStack {
                        Text(asset.name)
                        Spacer()
                        Text(asset.type.id)
                    }
                }
            }
            .toolbar {
                Button(action: {
                    isPresentingAssetAddView = true
                }, label: {
                    Image(systemName: "plus")
                })
                .accessibilityLabel("New Asset")
            }
            .searchable(text: $searchQuery) // New: Search bar
            .onChange(of: searchQuery, perform: { query in
                filterAssets(by: query)
            })
        }
        .navigationTitle("Assets")
        .onAppear {
            loadAssets()
        }
        .sheet(isPresented: $isPresentingAssetAddView) {
            AssetAddView(newAsset: $newAsset, isPresentingAssetAddView: $isPresentingAssetAddView) { newAsset in
                addAsset(asset: &newAsset)
                newAsset = AssetData()
            }
        }
    }

    func loadAssets() {
        // Fetch assets using repository and update the view
        DispatchQueue.global(qos: .background).async {
            let loadedAssets = repository.load()
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.assets = loadedAssets
                self.filteredAssets = loadedAssets // Ensure filteredAssets is initialized with all assets
            }
        }
    }

    func addAsset(asset: inout AssetData) {
        // TODO
        if self.repository.insert(&asset) {
            self.assets.append(asset) // id is ready after repo call
            // loadAssets()
        } else {
            // TODO
        }
    }

    // New: Filter assets based on the search query
    func filterAssets(by query: String) {
        if query.isEmpty {
            filteredAssets = assets
        } else {
            filteredAssets = assets.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }
    }
}

#Preview {
    AssetListView(
        databaseURL: URL(string: "path/to/database")!
    )
}

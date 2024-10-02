//
//  AssetListView.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/25.
//

import SwiftUI

struct AssetListView: View {
    @EnvironmentObject var env: EnvironmentManager // Access EnvironmentManager
    @State private var assets: [AssetData] = []
    @State private var filteredAssets: [AssetData] = [] // New: Filtered assets for search results
    @State private var newAsset = emptyAsset
    @State private var isPresentingAssetAddView = false
    @State private var searchQuery: String = "" // New: Search query
    static let emptyAsset = AssetData(
        status: AssetStatus.open
    )

    var body: some View {
        NavigationStack {
            List($filteredAssets) { $asset in // Use filteredAssets instead of assets
                NavigationLink(destination: AssetDetailView(asset: $asset)) {
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
            .searchable(text: $searchQuery, prompt: "Search by name") // New: Search bar
            .onChange(of: searchQuery) { _, query in
                filterAssets(by: query)
            }
        }
        .navigationTitle("Assets")
        .onAppear {
            loadAssets()
        }
        .sheet(isPresented: $isPresentingAssetAddView) {
            AssetAddView(newAsset: $newAsset, isPresentingAssetAddView: $isPresentingAssetAddView) { newAsset in
                addAsset(asset: &newAsset)
                newAsset = Self.emptyAsset
            }
        }
    }

    func loadAssets() {
        // Fetch assets using repository and update the view
        DispatchQueue.global(qos: .background).async {
            let loadedAssets = env.assetRepository?.load() ?? []
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.assets = loadedAssets
                self.filteredAssets = loadedAssets // Ensure filteredAssets is initialized with all assets
            }
        }
    }

    func addAsset(asset: inout AssetData) {
        guard let repository = env.assetRepository else { return }
        if repository.insert(&asset) {
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
    AssetListView()
        .environmentObject(EnvironmentManager())
}

//
//  ListProtocol.swift
//  MMEX
//
//  2024-10-26: Created by George Ef (george.a.ef@gmail.com)
//

@MainActor
protocol ListProtocol {
    associatedtype MainRepository: RepositoryProtocol

    var state : LoadState                     { get set }
    var count : LoadMainCount<MainRepository> { get set }
    var data  : LoadMainData<MainRepository>  { get set }
    var used  : LoadMainUsed<MainRepository>  { get set }
}

extension ViewModel {
    func loadList<ListType: ListProtocol>(_ list: ListType) async {
        typealias MainRepository = ListType.MainRepository
        /**/ if MainRepository.self == U.self { async let _ = loadCurrencyList() }
        else if MainRepository.self == A.self { async let _ = loadAccountList() }
        else if MainRepository.self == E.self { async let _ = loadAssetList() }
        else if MainRepository.self == S.self { async let _ = loadStockList() }
        else if MainRepository.self == C.self { async let _ = loadCategoryList() }
        else if MainRepository.self == P.self { async let _ = loadPayeeList() }
    }

    func unloadList<ListType: ListProtocol>(_ list: ListType) {
        typealias MainRepository = ListType.MainRepository
        /**/ if MainRepository.self == U.self { unloadCurrencyList() }
        else if MainRepository.self == A.self { unloadAccountList() }
        else if MainRepository.self == E.self { unloadAssetList() }
        else if MainRepository.self == S.self { unloadStockList() }
        else if MainRepository.self == C.self { unloadCategoryList() }
        else if MainRepository.self == P.self { unloadPayeeList() }
    }

    func loadList() async {
        async let _ = loadManageList()
        async let _ = loadCurrencyList()
        async let _ = loadAccountList()
        async let _ = loadAssetList()
        async let _ = loadStockList()
        async let _ = loadCategoryList()
        async let _ = loadPayeeList()
    }

    func unloadList() {
        unloadManegeList()
        unloadCurrencyList()
        unloadAccountList()
        unloadAssetList()
        unloadStockList()
        unloadCategoryList()
        unloadPayeeList()
    }
}

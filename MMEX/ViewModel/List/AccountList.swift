//
//  AccountList.swift
//  MMEX
//
//  2024-10-26: Created by George Ef (george.a.ef@gmail.com)
//

import SQLite

struct AccountList: ListProtocol {
    typealias MainRepository = AccountRepository

    var state : LoadState                     = .init()
    var count : LoadMainCount<MainRepository> = .init()
    var data  : LoadMainData<MainRepository>  = .init()
    var order : LoadMainOrder<MainRepository> = .init(order: [MainRepository.col_name])
    var used  : LoadMainUsed<MainRepository>  = .init()
    var att   : LoadAuxAtt<MainRepository>    = .init()

    var name  : LoadMainName<MainRepository>  = .init { $0[MainRepository.col_name] }
}

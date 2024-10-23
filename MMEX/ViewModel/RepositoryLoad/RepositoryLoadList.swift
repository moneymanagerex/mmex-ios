//
//  RepositoryLoadList.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

/*
typealias RepositoryLoadList<MainRepository: RepositoryProtocol>
= RepositoryLoadState<Void>
*/

struct RepositoryLoadList<MainRepository: RepositoryProtocol> {
    var state: RepositoryLoadState<Void> = .init()
}

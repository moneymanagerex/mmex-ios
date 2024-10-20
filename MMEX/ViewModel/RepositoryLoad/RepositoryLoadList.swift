//
//  RepositoryLoad.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

import SwiftUI

struct RepositoryLoadList<RepositoryType: RepositoryProtocol> {
    let type = RepositoryType.self
    var state: RepositoryLoadState<Void> = .init()
}

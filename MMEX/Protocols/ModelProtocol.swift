//
//  ModelProtocal.swift
//  MMEX
//
//  Created 2024-09-22 by George Ef (george.a.ef@gmail.com)
//

import Foundation

protocol ModelProtocol {
    static var modelName: String { get }

    var id: Int64 { get set }
    func shortDesc() -> String
}
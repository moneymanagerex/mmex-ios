//
//  SearchArea.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

typealias SearchArea<MainData: DataProtocol> = (
    name: String,
    isSelected: Bool,
    values: [(MainData) -> String]
)

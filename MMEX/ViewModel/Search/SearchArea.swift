//
//  SearchArea.swift
//  MMEX
//
//  2024-10-20: Created by George Ef (george.a.ef@gmail.com)
//

// TODO: search in AuxData (e.g., tags, attachments, txn splits)
typealias SearchArea<MainData: DataProtocol> = (
    name: String,
    isSelected: Bool,
    mainValues: [(MainData) -> String],
    auxValues: [(ViewModel, MainData) -> String]
)

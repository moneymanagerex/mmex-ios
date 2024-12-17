//
//  MMEXDocument.swift
//  MMEX
//
//  Created 2024-09-24 by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import SQLite

extension UTType {
    static var mmb: UTType { UTType(exportedAs: "com.guangong.mmex.mmb") }
    static var emb: UTType { UTType(exportedAs: "com.guangong.mmex.emb") }
}

struct MMEXDocument: FileDocument {
    static var readableContentTypes: [UTType] = [UTType.mmb, UTType.emb]

    init() { }
    init(configuration: ReadConfiguration) throws { }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper()
    }
}

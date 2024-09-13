//
//  ExportableEntityDocument.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/13.
//

import SwiftUI
import UniformTypeIdentifiers

struct ExportableEntityDocument<T: ExportableEntity>: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var entity: T
    
    init(entity: T) {
        self.entity = entity
    }
    
    init(configuration: ReadConfiguration) throws {
        self.entity = try JSONDecoder().decode(T.self, from: configuration.file.regularFileContents ?? Data())
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let jsonData = try JSONEncoder().encode(entity)
        return FileWrapper(regularFileWithContents: jsonData)
    }
}

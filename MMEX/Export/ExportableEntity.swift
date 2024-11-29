//
//  ExportableEntity.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/13.
//

import Foundation
import SwiftUI

protocol ExportableEntity: Identifiable, Codable {
    func export() -> String?
    func copyToPasteboard()
}

extension ExportableEntity {
    
    // Default export as a JSON string
    func export() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // Copy the JSON string to pasteboard
    func copyToPasteboard() {
        if let exportString = self.export() {
            log.debug("DEBUG: ExportableEntity.copyToPasteboard(): \(exportString)")
            UIPasteboard.general.string = exportString
        }
    }
}

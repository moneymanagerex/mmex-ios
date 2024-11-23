//
//  Appearance.swift
//  MMEX
//
//  2024-11-15: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation
import SwiftUI

enum Appearance: String, EnumCollateNoCase {
    case system = "System"
    case light  = "Light"
    case dark   = "Dark"
    static let defaultValue = Self.system

    var asUIStyle: UIUserInterfaceStyle {
        return switch self {
        case .system : UIUserInterfaceStyle.unspecified
        case .light  : UIUserInterfaceStyle.light
        case .dark   : UIUserInterfaceStyle.dark
        }
    }
}

extension Appearance {
    func apply() {
        log.debug("DEBUG: Appearance.apply(\(self.rawValue))")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = self.asUIStyle
                window.reloadInputViews()
            }
        }
    }
}

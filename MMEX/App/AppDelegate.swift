//
//  AppDelegate.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/12/16.
//

import UIKit
import OSLog
import MobileCoreServices


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        log.debug("File opened with URL: \(url)")

        // Ensure it's an .mmb file
        guard url.pathExtension == "mmb" else {
            log.error("Unsupported file type: \(url.pathExtension)")
            return false
        }

        // Handle the .mmb file (pass it to your ViewModel or other logic)
        handleMMBFile(url)

        return true
    }

    private func handleMMBFile(_ url: URL) {
        log.debug("Processing .mmb file at: \(url.path)")
        
        // Example: pass the URL to your ViewModel
        NotificationCenter.default.post(
            name: Notification.Name("MMEXOpenFile"),
            object: url
        )
    }
}

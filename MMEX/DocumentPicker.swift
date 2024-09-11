//
//  DocumentPicker.swift
//  MMEX
//
//  Created by Lisheng Guan on 2024/9/5.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers
import SQLite3
 
struct DocumentPicker: UIViewControllerRepresentable {
     @Binding var selectedFileURL: URL?

     func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
         let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
         picker.delegate = context.coordinator
         return picker
     }

     func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

     func makeCoordinator() -> Coordinator {
         return Coordinator(self)
     }

     class Coordinator: NSObject, UIDocumentPickerDelegate {
         var parent: DocumentPicker

         init(_ parent: DocumentPicker) {
             self.parent = parent
         }

         func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
             guard let selectedURL = urls.first else { return }

             // Handle security-scoped resource access
             if selectedURL.startAccessingSecurityScopedResource() {
                 DispatchQueue.main.async {
                     self.parent.selectedFileURL = selectedURL
                 }
                 
                 // Save the file path for later access
                 UserDefaults.standard.set(selectedURL.path, forKey: "SelectedFilePath")

                 selectedURL.stopAccessingSecurityScopedResource() // Stop when done
             } else {
                 print("Unable to access file at URL: \(selectedURL)")
             }

             controller.dismiss(animated: true, completion: nil)
         }

         func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
             print("Document picker was cancelled.")
             controller.dismiss(animated: true, completion: nil)
         }
     }

 }

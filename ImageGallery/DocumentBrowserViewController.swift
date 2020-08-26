//
//  DocumentBrowserViewController.swift
//  ImageGallery
//
//  Created by Dmitry Reshetnik on 24.08.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    var template: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        allowsDocumentCreation = false
        allowsPickingMultipleItems = false
        
        // Update the style of the UIDocumentBrowserViewController
        // browserUserInterfaceStyle = .dark
        // view.tintColor = .white
        
        // Specify the allowed content types of your application via the Info.plist.

        // Do any additional setup after loading the view.
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            template = try? FileManager.default.url(
                for: FileManager.SearchPathDirectory.applicationSupportDirectory,
                in: FileManager.SearchPathDomainMask.userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("Untitled.json")
            
            if template != nil {
                allowsDocumentCreation = FileManager.default.createFile(atPath: template!.path, contents: Data(), attributes: nil)
            }
        }
    }
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        // Set the URL for the new document here. Optionally, you can present a template chooser before calling the importHandler.
        // Make sure the importHandler is always called, even if the user cancels the creation request.
        if template != nil {
            importHandler(template, UIDocumentBrowserViewController.ImportMode.copy)
        } else {
            importHandler(nil, UIDocumentBrowserViewController.ImportMode.none)
        }
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let imageGalleryViewController = storyBoard.instantiateViewController(identifier: "ImageGallery")
        
        if let imageGallery = imageGalleryViewController.contents as? ImageGalleryCollectionViewController {
            imageGallery.document = ImageGalleryDocument(fileURL: documentURL)
        }
        
        imageGalleryViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        present(imageGalleryViewController, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  Utilities.swift
//  Sift
//
//  Created by Brandon Kane on 6/13/20.
//  Copyright © 2020 Brandon Kane. All rights reserved.
//

import Foundation
import CloudKit
import Realm


class Utilities {
        
    struct DocumentsDirectory {
        static let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last!
        static let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }
    
    func isCloudEnabled() -> Bool {
        if DocumentsDirectory.iCloudDocumentsURL != nil { return true }
        else { return false }
    }
    
    func saveRealm() {
        uploadDatabaseToCloudDrive()
//        let realmArchiveURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("test.realm")
//        try! Database.shared.realm.writeCopy(toFile: realmArchiveURL!)
        
        
    }
    
    func uploadDatabaseToCloudDrive() {
        guard isCloudEnabled() else { return }

//        self.checkForExistingDir()

        let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents", isDirectory: true)

        let iCloudDocumentToCheckURL = iCloudDocumentsURL?.appendingPathComponent("default.realm", isDirectory: false)

        let realmArchiveURL = iCloudDocumentToCheckURL!

        
        if FileManager.default.fileExists(atPath: realmArchiveURL.path) {
            do {
                try FileManager.default.removeItem(at: realmArchiveURL)
                print("replacing")
                try! Database.shared.realm.writeCopy(toFile: realmArchiveURL)
            } catch {
                print("error saving realm")
            }
        } else {
            print("need to store")
            try! Database.shared.realm.writeCopy(toFile: realmArchiveURL)
        }
    }
}

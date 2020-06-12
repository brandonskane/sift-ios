//
//  Database.swift
//  Sift
//
//  Created by Brandon Kane on 6/7/20.
//  Copyright © 2020 Brandon Kane. All rights reserved.
//

import Foundation
import RealmSwift

class Database {
    let realm: Realm!
    static let shared = Database()
    
    init(readOnly: Bool = false) {
        var config = Realm.Configuration()
        
        let fileURL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier)!
        .appendingPathComponent("data/default.realm")
        
        config.fileURL = fileURL
        config.readOnly = readOnly
        Realm.Configuration.defaultConfiguration = config
        
        // create file if it doesn't exist
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier)?.appendingPathComponent("data")
        if !FileManager.default.fileExists(atPath: directory!.absoluteString) {
            try! FileManager.default.createDirectory(at: directory!, withIntermediateDirectories: true, attributes: nil)
        }
        
        realm = try! Realm()
    }
    
    static func doesDatabaseExist() -> Bool {
        let fileURL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier)!
        .appendingPathComponent("data/default.realm")
        
        return FileManager.default.isReadableFile(atPath: fileURL.absoluteString)
    }
    
    func getApp(bundleId: String) -> App {
        let app = realm.object(ofType: App.self, forPrimaryKey: bundleId)
        //.filter("bundleId = '\(bundleId)'")
        if let existingApp = app {
            return existingApp
        } else {
            return createApp(bundleId: bundleId)
        }
    }
    
    func createApp(bundleId: String) -> App {
        let newApp = App()
        newApp.bundleId = bundleId
        newApp.commonNameFromBundle()
        
        try! realm.write {
            realm.add(newApp)
        }
        return newApp
    }
    
    func updateCommonNameFor(app: App, commonName: String? = nil) {
        try! realm.write {
            if let commonName = commonName {
                app.commonName = commonName
            } else {
                app.commonNameFromBundle()
            }
            
        }
    }
    
    func getAllHosts() -> Results<Host> {
        return realm.objects(Host.self)
    }
    
    func getHost(hostname: String, ifExistsOnly: Bool = false) -> Host? {
        let host = realm.object(ofType: Host.self, forPrimaryKey: hostname)
        if let existingHost = host {
            return existingHost
        } else {
            guard !ifExistsOnly else { return nil }
            return createHost(hostname: hostname)
        }
    }
    
    @discardableResult
    func createHost(hostname: String, isAllowed: Bool = true, category: HostCategory = .uncategorized) -> Host {
        let newHost = Host()
        newHost.hostname = hostname
        newHost.isAllowed = isAllowed
        newHost.evaulated = !isAllowed
        if category != .uncategorized {
            newHost.category = category.rawValue
        }
        
        try! realm.write {
            realm.add(newHost)
        }
        return newHost
    }
    
    func markHostAsEvaulated(host: Host) {
        try! realm.write {
            host.evaulated = true
        }
    }
    
    func markHostAsBlocked(host: Host) {
        try! realm.write {
            host.isAllowed = false
        }
    }
    
    func markHostAsUnblocked(host: Host) {
        try! realm.write {
            host.isAllowed = true
        }
    }
    
    func addAppToAllowedListFor(host: Host, app: App) {
        try! realm.write {
            host.allowedApps.append(app)
        }
    }
    
    func addHostToAppListFor(app: App, host: Host) {
        try! realm.write {
            app.hosts.append(host)
        }
    }
    
    func addBlockedAppTo(host: Host, app: App) {
        try! realm.write {
            host.blockedApps.append(app)
        }
    }
}

extension Realm {
    func writeAsync<T : ThreadConfined>(obj: T, errorHandler: @escaping ((_ error : Swift.Error) -> Void) = { _ in return }, block: @escaping ((Realm, T?) -> Void)) {
        let wrappedObj = ThreadSafeReference(to: obj)
        let config = self.configuration
        DispatchQueue(label: "background").async {
            autoreleasepool {
                do {
                    let realm = try Realm(configuration: config)
                    let obj = realm.resolve(wrappedObj)

                    try realm.write {
                        block(realm, obj)
                    }
                }
                catch {
                    errorHandler(error)
                }
            }
        }
    }
}

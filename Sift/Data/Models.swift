//
//  Models.swift
//  Sift
//
//  Created by Brandon Kane on 6/7/20.
//  Copyright © 2020 Brandon Kane. All rights reserved.
//

import RealmSwift

class App: Object {
    @objc dynamic var bundleId = ""
    @objc dynamic var commonName = ""
    let hosts = List<Host>()
    let allowedHosts = LinkingObjects(fromType: Host.self, property: "allowedApps")
    let blockedHosts = LinkingObjects(fromType: Host.self, property: "blockedApps")
    
    override static func primaryKey() -> String? {
      return "bundleId"
    }
}


extension App {
    func commonNameFromBundle() {
        self.commonName = self.bundleId.components(separatedBy: ".").last ?? self.bundleId
    }
}

enum HostCategory: String {
    case ad, tracker, analytics, misc, unknown, uncategorized
}

class Host: Object {
    @objc dynamic var hostname = ""
    @objc dynamic var isAllowed = true
    @objc dynamic var evaulated = false
    @objc dynamic var blockCount = 0
    @objc dynamic var lastSeen = Date() //rename to first seen
    @objc dynamic var category: String? = nil
    let allowedApps = List<App>()
    let blockedApps = List<App>()
    let apps = LinkingObjects(fromType: App.self, property: "hosts")
    
    override static func primaryKey() -> String? {
      return "hostname"
    }
}

extension Host {
    var categoryType: HostCategory {
        guard let category = self.category,
            let categoryEnum = HostCategory(rawValue: category) else { return .uncategorized }
        return categoryEnum
    }
}



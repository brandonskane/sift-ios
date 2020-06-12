//
//  FilterControlProvider.swift
//  SiftControl
//
//  Created by Brandon Kane on 12/23/17.
//  Copyright © 2020 Brandon Kane. All rights reserved.
//

import NetworkExtension
import UserNotifications
import os.log

class FilterControlProvider: NEFilterControlProvider {
    let mutex = Mutex()
    
    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow, completionHandler: @escaping (NEFilterControlVerdict) -> Void) {
        print("handleNewFlow")
        guard let appBundleId = flow.sourceAppIdentifier
        else {
            completionHandler(.allow(withUpdateRules: false))
            return
        }
        
        guard let hostname = flow.getHost() else {
            completionHandler(.allow(withUpdateRules: false))
            return
        }
        
        DispatchQueue.main.async {
            let app = Database.shared.getApp(bundleId: appBundleId)
                
            if let existingHost = Database.shared.getHost(hostname: hostname,
                                                          ifExistsOnly: true) {
                if existingHost.isAllowed {
                    completionHandler(.allow(withUpdateRules: false))
                } else {
                    completionHandler(.drop(withUpdateRules: false))
                }
                
                if !existingHost.apps.contains(app) {
                    Database.shared.addHostToAppListFor(app: app, host: existingHost)
                }
                
            } else {
                if !(UserDefaults.group?.bool(forKey: Constants.pushActivityKey) ?? false) {
                    self.fireNotification(app: appBundleId, hostname: hostname)
                }
                let newHost = Database.shared.createHost(hostname: hostname)
                Database.shared.addHostToAppListFor(app: app, host: newHost)
                completionHandler(.allow(withUpdateRules: true))
            }
            
//            if !host.isAllowed && !host.apps.contains(app) {
//                Database.shared.addHostToAppListFor(app: app, host: host)
//                completionHandler(.drop(withUpdateRules: false))
//            } else if !host.isAllowed && host.apps.contains(app) {
//                completionHandler(.drop(withUpdateRules: false))
//            } else if host.isAllowed && host.apps.contains(app) {
//                completionHandler(.allow(withUpdateRules: false))
//            } else {
//                Database.shared.addHostToAppListFor(app: app, host: host)
//                completionHandler(.allow(withUpdateRules: false))
//            }
            
//            if !host.isAllowed {
//                if host.blockedApps.contains(app) {
//                    //block
//                    completionHandler(.drop(withUpdateRules: false))
//                } else if host.allowedApps.contains(app) {
//                    //allow
//                    completionHandler(.allow(withUpdateRules: false))
//                } else {
//                    Database.shared.addBlockedAppTo(host: host, app: app)
//                    //block
//                    completionHandler(.drop(withUpdateRules: true))
//                }
//            } else if !host.allowedApps.contains(app) {
//                Database.shared.addAppToAllowedListFor(host: host, app: app)
//                Database.shared.addHostToAppListFor(app: app, host: host)
//                //allow
//                completionHandler(.allow(withUpdateRules: true))
//            }
        }
    }
    
    func fireNotification(app:String, hostname:String) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notes in
//            let appNotes = notes.filter {
//                $0.request.content.threadIdentifier == app
//            }
//
//            let oldNotes = appNotes.filter {
//                $0.date < Date().addingTimeInterval(-100)
//            }
//
//            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: oldNotes.map{ $0.request.identifier })
            
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = Constants.notificationCategory
            content.userInfo = ["app": app, "host": hostname]            
            content.body = app
            content.title = hostname
            content.threadIdentifier = app
            
            let id = UUID().uuidString
            
            let note = UNNotificationRequest(identifier: id,
                                             content: content,
                                             trigger: nil)
            
            
            UNUserNotificationCenter.current().add(note) { (err) in
                if err != nil {
                    print("err: \(err!)")
                }
            }
        }
        
    }
    
    func fireErrorNotification(error:String) {
        let content = UNMutableNotificationContent()
        content.title = "Error Showing Request"
        content.body = error
    
        
        let note = UNNotificationRequest(identifier: "sift_error_\(Date().timeIntervalSinceNow)",
                                         content: content,
                                         trigger: nil)
        
        UNUserNotificationCenter.current().add(note) { (err) in
            if err != nil {
                print("err: \(err!)")
            }
        }
    }
}



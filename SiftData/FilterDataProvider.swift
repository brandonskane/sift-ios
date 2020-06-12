//
//  FilterDataProvider.swift
//  SiftData
//
//  Created by Brandon Kane on 12/23/17.
//  Copyright © 2020 Brandon Kane. All rights reserved.
//

import NetworkExtension

class FilterDataProvider: NEFilterDataProvider {
    
    

    override init() {
        super.init()
    }
    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        // Add code to initialize the filter.
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code to clean up filter resources.
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        guard  let app = flow.sourceAppIdentifier
        else {
            return .allow()
        }
        
        let host = flow.getHost()
        
        // ignore exceptions
        if Set(StaticRules.apps).contains(app) {
            return .allow()
        }

        if let host = host, Set(StaticRules.hosts).contains(host) {
            return .allow()
        }
        
        var verdict: NEFilterNewFlowVerdict = .allow()
        
        if let host = host {
            if let existingHost = Database(readOnly: true).getHost(hostname: host,
                                                                   ifExistsOnly: true) {
                verdict = existingHost.isAllowed ? NEFilterNewFlowVerdict.allow() : NEFilterNewFlowVerdict.drop()
                print("have the host: \(existingHost.isAllowed)")
            } else {
                print("no existing host: needRules ")
                verdict = .needRules()
            }
        } else {
            print("no URL?????????? .needRules()")
            verdict = .needRules()
        }
        
        return verdict
        
        
//        return .needRules()

        // try to get the rule or ask for an update
//        do {
//            guard let rule = try RuleManager().getRule(for: app, hostname: host)
//            else {
//                return .needRules()
//            }
//
//            return rule.isAllowed ? .allow() : .drop()
//
//        } catch {
//            return .needRules()
//        }
    }
}

//
//  Flow.swift
//  Sift
//
//  Created by Brandon Kane on 12/30/17.
//  Copyright © 2020 Brandon Kane. All rights reserved.
//

import Foundation
import NetworkExtension

extension NEFilterFlow {
    func getHost() -> String? {
        if let host = self.url?.host {
            return host
        }
        
        switch self {
        case let browserFlow as NEFilterBrowserFlow:
            return browserFlow.request?.url?.absoluteString
        case let _ as NEFilterSocketFlow:
//            var endpoint = "unknown"
//            if let neEndpoint = socketFlow.remoteEndpoint {
//                endpoint = "\(neEndpoint)"
//            }
//
//            return "socket: \(endpoint)"
            return nil
        default:
            return nil
        }

    }
}

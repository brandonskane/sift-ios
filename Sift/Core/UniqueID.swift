//
//  UniqueID.swift
//  Sift
//
//  Created by Brandon Kane on 12/24/17.
//  Copyright © 2020 Brandon Kane. All rights reserved.
//

import Foundation
import CommonCrypto

func uniqueIdentifier(of attrs:String...) -> String {
    var input = ""
    attrs.forEach {
        input += $0.SHA256.hex
    }
    
    return String(input.SHA256.hex.suffix(16))
}


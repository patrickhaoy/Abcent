//
//  TextChecker.swift
//  Abcent-Swift
//
//  Created by Henry Gu on 10/26/19.
//  Copyright © 2019 Patrick Yin. All rights reserved.
//

import Foundation
import UIKit

class TextChecker {
    let id: String!
    let original: String!
    let transcript: String!
    
    init(id: String, original: String, transcript: String) {
        self.id = id
        self.original = original
        self.transcript = transcript
    }
}

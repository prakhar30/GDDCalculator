//
//  Info.swift
//  gddCalculator
//
//  Created by Mallika Tiwari on 27/07/16.
//  Copyright © 2016 Mallika Tiwari. All rights reserved.
//

import Foundation
import UIKit

class Data {
    var time: String
    var avgTemp: String

    init(t: String, temp: String) {
        self.time = t
        self.avgTemp = temp
    }
}

class Data2 {
    var time: String
    var avgTemp: String
    var minTemp: String
    var maxTemp: String
    
    init(t: String, temp: String, min: String, max:String) {
        self.time = t
        self.avgTemp = temp
        self.minTemp = min
        self.maxTemp = max
    }
}

//
//  GlobalVariables.swift
//  TinyTaxi
//
//  Created by Johannes Boehm on 06/03/17.
//  Copyright © 2017 Johannes Boehm. All rights reserved.
//

import Foundation

class GlobalVariables {
    var currentLevel: Int
    init(currentLevel: Int){
        self.currentLevel = currentLevel
    }
}

var global = GlobalVariables(currentLevel: 1)

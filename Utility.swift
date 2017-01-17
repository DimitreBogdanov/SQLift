//
//  Utility.swift
//  SQLite
//
//  Created by Dimitre Bogdanov on 2016-11-07.
//
//

import Foundation

func timeString(unit:Int)->String{
    if unit < 10{
        return "0\(unit)"
    }
    return "\(unit)"
}

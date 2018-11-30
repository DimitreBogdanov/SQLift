//
//  Extensions.swift
//  Pods-SQLift_Tests
//
//  Created by Dimitre Bogdanov on 2018-11-27.
//

import Foundation

/**
 Extension to String class to perform validation
 */
extension String{
    //Valid if trimmed string is not empty
    func isValid()->Bool{
        return !self.trim().isEmpty
    }
    //Trim white spaces
    func trim()->String{
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    //Split with the given separator
    func split(_ separator:Character)->[String]{
        return self.split{$0 == separator}.map(String.init)
    }
}



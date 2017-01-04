//
//  DatabaseException.swift
//  SQLite
//
//  Created by Dimitre Bogdanov on 2016-03-08.
//  Copyright © 2016 Dimitre Bogdanov. All rights reserved.
//

import Foundation

enum DatabaseException : Error{
    //Connection errors
    case openingError(error:String)
    case closingError(error:String)
    case executionError(error:String)
    
    //PreparedStatement errors
    case preparingError(error:String)
    case resetError(error:String)
    case destroyingError(error:String)
    case selectError(error:String)
    case updateError(error:String)
    
    //ResultSet errors
}

//
//  DatabaseException.swift
//  SQLite
//
//  Created by Dimitre Bogdanov on 2016-03-08.
//  Copyright © 2016 Dimitre Bogdanov. All rights reserved.
//

import Foundation

enum DatabaseException : ErrorType{
    //Connection errors
    case OpeningError(error:String)
    case ClosingError(error:String)
    case ExecutionError(error:String)
    
    //PreparedStatement errors
    case PreparingError(error:String)
    case ResetError(error:String)
    case DestroyingError(error:String)
    case SelectError(error:String)
    case UpdateError(error:String)
    
    //ResultSet errors
}
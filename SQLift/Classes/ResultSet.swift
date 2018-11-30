//
//  ResultSet.swift
//  SQLite
//
//  Created by Dimitre Bogdanov on 2016-02-16.
//  Copyright © 2016 Dimitre Bogdanov. All rights reserved.
//

import Foundation
import SQLite3

//Class used as a collection of results returned from the query
class ResultSet{
    
    //sqlite3 representation of types
    static let TYPE_INT = 1
    static let TYPE_FLOAT = 2
    static let TYPE_TEXT = 3
    static let TYPE_BLOB = 4
    static let TYPE_NIL = 5
    static let TYPE_DATE = 6
    
    //NSDate precision
    static let SECOND = 0
    static let MINUTE = 1
    static let HOUR = 2
    static let DAY = 3
    static let MONTH = 4
    static let YEAR = 5
    
    //Reference to the prepared statement pointer
    fileprivate var handle:OpaquePointer? = nil
    //Wether or not the result was sucessful
    var isSuccessful:Bool = false
    //Any errors that would occurr are added to this array
    var errors:[String] = []
    //The current row of the step
    fileprivate var currentRow:[String:Int32] = [:]
    
    //Class initializer with the reference to the prepared statement pointer
    init(pointer:OpaquePointer?){
        handle = pointer
    }
    
    //Will return true if the collection contains a following row
    func next()->Bool{
        if sqlite3_step(handle) == SQLITE_ROW {
            fetchRow()
            return true
        }
        return false
    }
    
    ///////////////////////////////////////////////////////
    //            Get values using column name           //
    ///////////////////////////////////////////////////////
    
    //Retrieve an Int value using the provided column name
    func getInt(_ index:String)->Int32{
        return sqlite3_column_int(handle,currentRow[index.lowercased()]!)
    }
    
    //Retrieve a String value using the provided column name
    func getString(_ index:String)->String{
        return sqlite3_column_text(handle, currentRow[index.lowercased()]!) == nil ? "" : String(cString:(sqlite3_column_text(handle, currentRow[index.lowercased()]!)))
    }
    
    //Retrieve a Double value using the provided column name
    func getDouble(_ index:String)->Double{
        return sqlite3_column_double(handle, currentRow[index.lowercased()]!)
    }
    
    //Retrieve a Bool value using the provided column name
    //When retrieving, this translates to returning 'true' if the value is greater than 0
    //If the value is 0 or less, it will be treated as a 'false'
    func getBool(_ index:String)->Bool{
        return ((sqlite3_column_int(handle, currentRow[index.lowercased()]!) > 0) ? true : false)
    }
    
    
    //Retrieve an NSDate value using the provided column name
    //NSDate object has prevision up to the second
    func getDate(_ index:String, precision:Int)->Date{
        let unformattedString = getString(index)
        let unformattedDateTime = unformattedString.split(separator: " ")
        let unformattedDateString:String = String(unformattedDateTime[0])
        let unformattedTimeString:String = String(unformattedDateTime[1])
        let unformattedDate = unformattedDateString.split(separator: "-")
        let unformattedTime = unformattedTimeString.split(separator: ":")
        
        let year = String(unformattedDate[0])
        let month = String(unformattedDate[1])
        let day = String(unformattedDate[2])
        
        let hour = String(unformattedTime[0])
        let minute = String(unformattedTime[1])
        let second = String(unformattedTime[2])
        
        var c:DateComponents = DateComponents()
        c.hour = 0
        
        switch precision{
        case ResultSet.SECOND:
            c.second = Int(second)!
            fallthrough
        case ResultSet.MINUTE:
            c.minute = Int(minute)!
            fallthrough
        case ResultSet.HOUR:
            c.hour = Int(hour)!
            fallthrough
        case ResultSet.DAY:
            c.day = Int(day)!
            fallthrough
        case ResultSet.MONTH:
            c.month = Int(month)!
            fallthrough
        case ResultSet.YEAR:
            c.year = Int(year)!
            break
        default: break
        }
        
        let newDate = Calendar(identifier: Calendar.Identifier.gregorian).date(from: c)
        
        return newDate!
    }
    
    //Retrieve the type of the given column name
    func getType(_ index:String)->Int32{
        return sqlite3_column_type(handle,currentRow[index.lowercased()]!)
    }
    
    //Retrieve the value of a column depending on the column type
    func getValue(_ index:String) -> Any?{
        switch sqlite3_column_type(handle, currentRow[index.lowercased()]!){
        case SQLITE_INTEGER:
            return getInt(index)
        case SQLITE_FLOAT:
            return getDouble(index)
        case SQLITE3_TEXT:
            return getString(index)
        case SQLITE_BLOB:
            return nil
        case SQLITE_NULL:
            return nil
        default:
            return nil
        }
    }
    
    ///////////////////////////////////////////////////////
    //            Get values using column index          //
    ///////////////////////////////////////////////////////
    
    //Retrieve an Int value using the provided column index
    func getInt(_ index:Int32)->Int32{
        return sqlite3_column_int(handle,index)
    }
    
    //Retrieve a String value using the provided column index
    func getString(_ index:Int32)->String{
        return String(cString: (sqlite3_column_text(handle, index)))
    }
    
    //Retrieve a Double value using the provided column index
    func getDouble(_ index:Int32)->Double{
        return sqlite3_column_double(handle, index)
    }
    
    //Retrieve a Bool value using the provided column index
    //When retrieving, this translates to returning 'true' if the value is greater than 0
    //If the value is 0 or less, it will be treated as a 'false'
    func getBool(_ index:Int32)->Bool{
        return ((sqlite3_column_int(handle, index) > 0) ? true : false)
    }
    
    //Retrieve an NSDate value using the provided column index
    //NSDate object has prevision up to the minute
    func getDate(_ index:Int32, precision:Int)->Date{
        let unformattedString = getString(index)
        let unformattedDateTime = unformattedString.split(separator: " ")
        let unformattedDateString:String = String(unformattedDateTime[0])
        let unformattedTimeString:String = String(unformattedDateTime[1])
        let unformattedDate = unformattedDateString.split(separator: "-")
        let unformattedTime = unformattedTimeString.split(separator: ":")
        
        let year = String(unformattedDate[0])
        let month = String(unformattedDate[1])
        let day = String(unformattedDate[2])
        
        let hour = String(unformattedTime[0])
        let minute = String(unformattedTime[1])
        let second = String(unformattedTime[2])
        
        var c:DateComponents = DateComponents()
        
        switch precision{
        case ResultSet.SECOND:
            c.second = Int(second)!
            fallthrough
        case ResultSet.MINUTE:
            c.minute = Int(minute)!
            fallthrough
        case ResultSet.HOUR:
            c.hour = Int(hour)!
            fallthrough
        case ResultSet.DAY:
            c.day = Int(day)!
            fallthrough
        case ResultSet.MONTH:
            c.month = Int(month)!
            fallthrough
        case ResultSet.YEAR:
            c.year = Int(year)!
            break
        default: break
        }
        
        let newDate = Calendar(identifier: Calendar.Identifier.gregorian).date(from: c)
        
        return newDate!
    }
    
    //Retrieve the type of the given column name
    func getType(_ index:Int32)->Int32{
        return sqlite3_column_type(handle,index)
    }
    
    //Retrieve the value of a column depending on the column type
    func getValue(_ index:Int32) -> Any?{
        switch sqlite3_column_type(handle, index){
        case SQLITE_INTEGER:
            return getInt(index)
        case SQLITE_FLOAT:
            return getDouble(index)
        case SQLITE3_TEXT:
            return getString(index)
        case SQLITE_BLOB:
            return nil
        case SQLITE_NULL:
            return nil
        default:
            return nil
        }
    }
    
    //Return the number of columns in the row
    func columnCount()->Int32{
        return sqlite3_column_count(handle)
    }
    
    //Retrieve the name of the column at a given index
    func getColumnName(_ index:Int32)->String{
        return String(cString: sqlite3_column_name(handle, index))
    }
    
    //Retrieve all the column values names from the current row and store them in a dictionary with the associated numeral index
    //This will allow anyone using this framework to retrieve column values either by index or by name
    fileprivate func fetchRow(){
        let count = sqlite3_column_count(handle)
        currentRow = [:]
        for i in 0...count-1{
            currentRow[String(cString: sqlite3_column_name(handle, i)).lowercased()] = i
        }
    }
    
}

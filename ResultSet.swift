//
//  ResultSet.swift
//  SQLite
//
//  Created by Dimitre Bogdanov on 2016-02-16.
//  Copyright © 2016 Dimitre Bogdanov. All rights reserved.
//

import Foundation

//Class used as a collection of results returned from the query
class ResultSet{
    
    //sqlite3 representation of types
    static let TYPE_INT = 1
    static let TYPE_FLOAT = 2
    static let TYPE_TEXT = 3
    static let TYPE_BLOB = 4
    static let TYPE_NIL = 5
    
    //Reference to the prepared statement pointer
    private var handle:COpaquePointer = nil
    //Wether or not the result was sucessful
    var isSuccessful:Bool = false
    //Any errors that would occurr are added to this array
    var errors:[String] = []
    //The current row of the step
    private var currentRow:[String:Int32] = [:]
    
    //Class initializer with the reference to the prepared statement pointer
    init(pointer:COpaquePointer){
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
    func getInt(index:String)->Int32{
        return sqlite3_column_int(handle,currentRow[index.lowercaseString]!)
    }
    
    //Retrieve a String value using the provided column name
    func getString(index:String)->String{
        return sqlite3_column_text(handle, currentRow[index.lowercaseString]!) == nil ? "" : String.fromCString(UnsafePointer<Int8>(sqlite3_column_text(handle, currentRow[index.lowercaseString]!)))!
    }
    
    //Retrieve a Double value using the provided column name
    func getDouble(index:String)->Double{
        return sqlite3_column_double(handle, currentRow[index.lowercaseString]!)
    }
    
    //Retrieve a Bool value using the provided column name
    //When retrieving, this translates to returning 'true' if the value is greater than 0
    //If the value is 0 or less, it will be treated as a 'false'
    func getBool(index:String)->Bool{
        return ((sqlite3_column_int(handle, currentRow[index.lowercaseString]!) > 0) ? true : false)
    }
    
    //Retrieve an NSDate value using the provided column name
    //NSDate object has prevision up to the second
    func getDate(index:String)->NSDate{
        let unformattedString = getString(index)
        let unformattedDateTime:[String] = unformattedString.split(" ")
        let unformattedDateString:String = unformattedDateTime[0]
        let unformattedTimeString:String = unformattedDateTime[1]
        let unformattedDate:[String] = unformattedDateString.split("-")
        let unformattedTime:[String] = unformattedTimeString.split(":")
        
        let year = unformattedDate[0]
        let month = unformattedDate[1]
        let day = unformattedDate[2]
        
        let hour = unformattedTime[0]
        let minute = unformattedTime[1]
        let second = unformattedTime[2]
        
        let c:NSDateComponents = NSDateComponents()
        c.year = Int(year)!
        c.month = Int(month)!
        c.day = Int(day)!
        c.hour = Int(hour)!
        c.minute = Int(minute)!
        c.second = Int(second)!
        
        let newDate = NSCalendar(identifier: NSCalendarIdentifierGregorian)?.dateFromComponents(c)
        
        return newDate!
    }
    
    //Retrieve the type of the given column name
    func getType(index:String)->Int32{
        return sqlite3_column_type(handle,currentRow[index.lowercaseString]!)
    }
    
    //Retrieve the value of a column depending on the column type
    func getValue(index:String) -> Any?{
        switch sqlite3_column_type(handle, currentRow[index.lowercaseString]!){
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
    func getInt(index:Int32)->Int32{
        return sqlite3_column_int(handle,index)
    }
    
    //Retrieve a String value using the provided column index
    func getString(index:Int32)->String{
        return String.fromCString(UnsafePointer<Int8>(sqlite3_column_text(handle, index)))!
    }
    
    //Retrieve a Double value using the provided column index
    func getDouble(index:Int32)->Double{
        return sqlite3_column_double(handle, index)
    }
    
    //Retrieve a Bool value using the provided column index
    //When retrieving, this translates to returning 'true' if the value is greater than 0
    //If the value is 0 or less, it will be treated as a 'false'
    func getBool(index:Int32)->Bool{
        return ((sqlite3_column_int(handle, index) > 0) ? true : false)
    }
    
    //Retrieve an NSDate value using the provided column index
    //NSDate object has prevision up to the second
    func getDate(index:Int32)->NSDate{
        let unformattedString = getString(index)
        let unformattedDateTime:[String] = unformattedString.split(" ")
        let unformattedDateString:String = unformattedDateTime[0]
        let unformattedTimeString:String = unformattedDateTime[1]
        let unformattedDate:[String] = unformattedDateString.split("-")
        let unformattedTime:[String] = unformattedTimeString.split(":")
        
        let year = unformattedDate[0]
        let month = unformattedDate[1]
        let day = unformattedDate[2]
        
        let hour = unformattedTime[0]
        let minute = unformattedTime[1]
        let second = unformattedTime[2]
        
        let c:NSDateComponents = NSDateComponents()
        c.year = Int(year)!
        c.month = Int(month)!
        c.day = Int(day)!
        c.hour = Int(hour)!
        c.minute = Int(minute)!
        c.second = Int(second)!
        
        let newDate = NSCalendar(identifier: NSCalendarIdentifierGregorian)?.dateFromComponents(c)
        
        return newDate!
    }

    
    //Retrieve the type of the given column name
    func getType(index:Int32)->Int32{
        return sqlite3_column_type(handle,index)
    }
    
    //Retrieve the value of a column depending on the column type
    func getValue(index:Int32) -> Any?{
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
    func getColumnName(index:Int32)->String{
        return String.fromCString(sqlite3_column_name(handle, index))!
    }
    
    //Retrieve all the column values names from the current row and store them in a dictionary with the associated numeral index
    //This will allow anyone using this framework to retrieve column values either by index or by name
    private func fetchRow(){
        let count = sqlite3_column_count(handle)
        currentRow = [:]
        for i in 0...count-1{
            currentRow[String.fromCString(sqlite3_column_name(handle, i))!.lowercaseString] = i
        }
    }
    
}

extension String{
    //Split with the given separator
    func split(separator:Character)->[String]{
        return self.characters.split{$0 == separator}.map(String.init)
    }
}

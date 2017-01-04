//
//  PreparedStatement.swift
//  SQLite
//
//  Created by Dimitre Bogdanov on 2016-02-16.
//  Copyright © 2016 Dimitre Bogdanov. All rights reserved.
//

import Foundation

//Class used to prepare SQL statements, usually while binding values
class PreparedStatement{
    
    //Pointer to the sql statement object used by the database to prepare the SQL
    fileprivate var statement: OpaquePointer? = nil
    //Reference to the database pointer used for the connection
    fileprivate var database:OpaquePointer? = nil
    //Should there be an error from a failure of operation, it would be stored in this variable
    var error:String = ""
    
    //Used for text binding
    internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    //Class initializer
    //Prepares the sql statement with the SQL provided and the database poitner using the v2 C api
    //Should there be an error while preparation, it would be stored in the _.error variable
    init(sql:String, db: inout OpaquePointer){
        database = db
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK{
            error = (NSString(utf8String: sqlite3_errmsg(statement)) as! String)
        }
    }
    
    //Class initializer
    //Prepares the sql statement with the SQL provided and the database poitner using the v2 C api
    //All values passed are automatically bound if the statement preparation does not fail
    //Should there be an error while preparation, it would be stored in the _.error variable
    init(sql:String, db: inout OpaquePointer, values:[Any]){
        database = db
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK{
            error = (NSString(utf8String: sqlite3_errmsg(statement)) as! String)
        }
        bindParameters(values)
    }
    
    //Loops through the provided parameters and binds them to the prepared statement
    func bindParameters(_ values:[Any]){
        for i in 0 ..< values.count{
            bindParameter((i + 1), value: values[i])
            if error.isValid(){
                return
            }
        }
    }
    
    //Binds a value at the given index
    //TODO blob, date implementation
    func bindParameter(_ index:Int32, value:Any?){
        if value == nil{
            if sqlite3_bind_null(statement, index) != SQLITE_OK{
                error = String(cString: sqlite3_errmsg(database))
                print(error)
                return
            }
        }else if value is Int{
            if sqlite3_bind_int(statement, index, Int32(value as! Int)) != SQLITE_OK{
                error = String(cString: sqlite3_errmsg(database))
                print(error)
                return
            }
        }else if value is String{
            if sqlite3_bind_text(statement, index, value as! String, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                error = String(cString: sqlite3_errmsg(database))
                print(error)
                return
            }
        }else if value is Double{
            if sqlite3_bind_double(statement, index, value as! Double) != SQLITE_OK{
                error = String(cString: sqlite3_errmsg(database))
                print(error)
                return
            }
        }else if value is Bool{
            if sqlite3_bind_int(statement, index, (value as! Bool) ? 1 : 0) != SQLITE_OK{
                error = String(cString: sqlite3_errmsg(database))
                print(error)
                return
            }
        }else if value is NSDate{
            let date:Date = value as! Date
            let calendar = Calendar.current
            let components = (calendar as NSCalendar).components([.day , .month , .year, .hour, .minute, .second], from: date)
            
            let year =  components.year
            let month = components.month
            let day = components.day
            let hour = components.hour
            let minute = components.minute
            let seconds = components.second
            
            
            
            let datetime:String = "\(year!)-\(Utility.timeString(month!))-\(Utility.timeString(day!)) \(Utility.timeString(hour!)):\(Utility.timeString(minute!)):\(Utility.timeString(seconds!))"
            if sqlite3_bind_text(statement, index, datetime, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                error = String(cString: sqlite3_errmsg(database))
                print(error)
                return
            }
        }else {
            //Doesnt work yet
            //sqlite3_bind_blob(statement, index, value, <#T##n: Int32##Int32#>, <#T##((UnsafeMutablePointer<Void>) -> Void)!##((UnsafeMutablePointer<Void>) -> Void)!##(UnsafeMutablePointer<Void>) -> Void#>)
        }
    }
    
    //Reset the prepared statement
    //Allows the statement to be reused afterwards
    //Returns false if the reset failed
    //_.error would contain any error if it does fail
    func reset()->Bool{
        if sqlite3_reset(statement) != SQLITE_OK{
            error = (NSString(utf8String: sqlite3_errmsg(statement)) as! String)
            return false
        }
        return true
    }
    
    //Destroys the prepared statement and frees up the memory
    //Returns false if the destroy operation failed
    //_.error would contain any error if it does fail
    func destroy()->Bool{
        if sqlite3_finalize(statement) != SQLITE_OK{
            error = (NSString(utf8String: sqlite3_errmsg(statement)) as! String)
            return false
        }
        statement = nil
        return true
    }
    
    //Execute a select statement
    //Used when expecting results to be returned from the query
    //Returns a ResultSet initialized with the pointer of the PreparedStatement
    func executeSelect()->ResultSet{
        let result = ResultSet(pointer:statement!)
        result.isSuccessful = true
        return result
    }
    
    //Execute a statement that would update/write to the database
    //Used in a situation where you would execute an UPDATE or INSERT INTO statement
    //Can throw a DatabaseException.ExecutionError
    //The error can either be retrieved through the _.error class member
    //Or it can be retrieved through the exception by using the following syntax
    //do{
    //  try _.executeUpdate()
    //}catch DatabaseException.ExecutionError(let error){
    // *error variable now contains the content of the error message*
    //}
    func executeUpdate()throws{
        if sqlite3_step(statement) != SQLITE_DONE{
            error = (NSString(utf8String: sqlite3_errmsg(statement)) as! String)
            throw DatabaseException.updateError(error: error)
        }
        _ = reset()
        _ = destroy()
    }
}

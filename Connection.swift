//
//  Connection.swift
//  SQLite
//
//  Created by Dimitre Bogdanov on 2016-02-16.
//  Copyright © 2016 Dimitre Bogdanov. All rights reserved.
//

import Foundation

//List of many of the possible sqlite errors returned
//0 being no errors
private let SQLITE_ERRORS:[Int32:String] = [
    1 : "SQL error or missing database",
    2 : "Internal logic error in SQLite",
    3 : "Access permission denied",
    4 : "Callback routine requested an abort",
    5 : "The database file is locked",
    6 : "A table in the database is locked",
    7 : "A malloc() failed",
    8 : "Attempt to write a readonly database",
    9 : "Operation terminated by sqlite3_interrupt()",
    10 : "Some kind of disk I/O error occurred",
    11 : "The database disk image is malformed",
    12 : "Unknown opcode in sqlite3_file_control()",
    13 : "Insertion failed because database is full",
    14 : "Unable to open the database file",
    15 : "Database lock protocol error",
    16 : "Database is empty",
    17 : "The database schema changed",
    18 : "String or BLOB exceeds size limit",
    19 : "Abort due to constraint violation",
    20 : "Data type mismatch",
    21 : "Library used incorrectly",
    22 : "Uses OS features not supported on host",
    23 : "Authorization denied",
    24 : "Auxiliary database format error",
    25 : "2nd parameter to sqlite3_bind out of range",
    26 : "File opened that is not a database file",
    27 : "Notifications from sqlite3_log()",
    28 : "Warnings from sqlite3_log()",
    100 : "sqlite3_step() has another row ready",
    101 : "sqlite3_step() has finished executing"
]

//Class used as a database connection to the given path
class Connection{
    
    //File path of the database
    fileprivate var filePath:String?
    //Pointer to the database object
    fileprivate var handle: OpaquePointer? = nil
    //Transaction used for savepoints (begin, rollback, commit)
    fileprivate let transaction:String = "GymBuddyTransaction"
    //Will contain the error message if there is one in case of failure of operation
    var errorMessage:String = ""
    
    //Class intializer
    //Sets the file path of the database
    internal init(filePath:String){
        self.filePath = filePath
    }
    
    //Allow for subclassing to adjust the database to be opened if using a singleton object.
    func setFilePath(_ path:String){
        self.filePath = path;
    }
    
    //Opens the database using the provided file path
    //Will return false if it failed to open
    //_.errorMessage class member contains more information on the error
    func open()->Bool{
        let error = sqlite3_open_v2((filePath?.cString(using: String.Encoding.utf8))!, &handle, SQLITE_OPEN_READWRITE, nil)
        if error != SQLITE_OK{
            self.errorMessage = (NSString(utf8String: sqlite3_errmsg(handle)) as! String)
            return false
        }
        errorMessage = ""
        return true
    }
    
    //Closes the database
    //Will return false if it failed to close
    //_.errorMessage class member contains more information on the error
    func close()->Bool{
        let error =  sqlite3_close_v2(handle)
        if error != SQLITE_OK{
            self.errorMessage = (NSString(utf8String: sqlite3_errmsg(handle)) as! String)
            return false
        }
        errorMessage = ""
        handle = nil
        return true
    }
    
    //IF USING BEGIN TRANSACTION, MUST EITHER USE COMMIT OR ROLLBACK
    //OTHERWISE FOLLOWING TRANSACTIONS MAY BE CORRUPTED
    
    //Begin a transaction using savepoint
    func begin(){
        do{
            try exec("SAVEPOINT \(transaction)")
        }catch DatabaseException.executionError(let err){
            print("Error opening transaction: \(err)")
        }catch{
            print("An error has occurred when opening the transaction")
        }
    }
    
    //Commit the transaction by releasing the savepoint
    func commit(){
        do{
            try exec("RELEASE SAVEPOINT \(transaction)")
        }catch DatabaseException.executionError(let err){
            print("Error commiting transaction: \(err)")
        }catch{
            print("An error has occurred when commiting the transaction")
        }
    }
    
    //Rollback the transaction by rolling back to the savepoint
    func rollback(){
        do{
            try exec("ROLLBACK TRANSACTION TO SAVEPOINT \(transaction)")
        }catch DatabaseException.executionError(let err){
            print("Error rolling back transaction: \(err)")
        }catch{
            print("An error has occurred when rolling back transaction")
        }
    }
    
    //Executes a raw SQL statement
    //Can throw a DatabaseException.ExecutionError
    //The error can either be retrieved through the _.errorMessage class member
    //Or it can be retrieved through the exception by using the following syntax
    //do{
    //  try _.exec(sql)
    //}catch DatabaseException.ExecutionError(let error){
    // *error variable now contains the content of the error message*
    //}
    func exec(_ statement:String)throws{
        if sqlite3_exec(handle, statement, nil, nil, nil) != SQLITE_OK{
            self.errorMessage = (NSString(utf8String: sqlite3_errmsg(handle)) as! String)
            throw DatabaseException.executionError(error: self.errorMessage)
        }
    }
    
    //Prepares a statement with the given SQL statement
    //This does not bind any parameters, it simply prepares the statement
    //Binding can either be done through the overloaded prepareStatement(sql:String, values [Any]) function call
    //Or it can be done by using the bindParameter()/bindParameters() functions of the PreparedStatement object
    func prepareStatement(_ sql:String)->PreparedStatement{
        return PreparedStatement(sql: sql, db:&handle!)
    }
    
    //Prepare a statement with the given SQL and values to bind
    //Using this call to prepareStatement() will automatically bind all the values, you do not have to do it yourself
    func prepareStatement(_ sql:String, values:[Any])->PreparedStatement{
        return PreparedStatement(sql: sql, db:&handle!, values: values)
    }
}

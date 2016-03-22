# SQLite
SQLite is a simple and very basic swift library used as a wrapper for the c/c++ sqlite3 library.
This project is still work in progress and only supports basic features.

### Note: this does not come with sqlite3 itself. Make sure it is included in your swift project otherwise the following code will not work.

## Usage

### Opening a database connection

```swift
//Where filePath is the path to the database file you would like to use
//Note: the database must already exist, otherwise an error will be returned
//This will open the database as read & write mode, if it is protected by the OS, it will be in read-only mode.
let db:Connection = Connection(filePath: String) 

if db.open(){
//Database successfully opened, you can begin transactions
}else{
//Database could not open, see error message for more details
print("Error opening the database: \(db.errorMessage)")
}
```

### Closing a database connection
```swift
if db.close(){
//Successfully closed
}else{
//Database could not close, see error message for more details
print("Error opening the database: \(db.errorMessage)")
}
```

### Performing transactions using begin, commit and rollback
```swift
//All transactions are used with savepoints

//*NOTE*
//IF USING BEGIN TRANSACTION, MUST EITHER USE COMMIT OR ROLLBACK
//OTHERWISE FOLLOWING TRANSACTIONS MAY BE CORRUPTED
//FUTURE IMPLEMENTATION MAY CHANGE THIS BUT FOR THE MOMENT IT IS NECESSARY

//This will essentially execute a savepoint statement
db.begin()

//This will release the savepoint, which in terms will commit it
db.commit()

//This will rollback to the initially declared savepoint
db.rollback()
```

### Executing a single statement with no results expected
```swift
let db = Connection(filePath: "test.db")
if !db.open(){
return
}
do{
    try db.exec("test")
}
catch DatabaseException.ExecutionError(let error){
    print("There was an error when executing the sql statement: \(error)")
}
catch let err as NSError{
     print("Something went wrong: \(err)")
}
```

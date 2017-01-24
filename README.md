# SQLift
SQLift is a simple and very basic swift library used as a wrapper for the c/c++ sqlite3 library.
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

### Preparing SQL statements
```swift
// Where 'values' is an array of type Any to bind to the sql statement and 'sq' is the SQL statement
// The values in the array will be replaced in order with the question marks in the sql statement
// Example: select * from table_name where col1 = ? and col2 = ?
// values = [1, "name"]
// Supported binding values:
// - String
// - Int
// - Double
// - nil
// - bool <=> Will bind 1 if true, 0 otherwise
// - NSDate <=> precision to the minute

let ps:PreparedStatement = db.prepareStatement("sql statement", values: [])
```

### Executing a prepared statement for update
```swift
if !db.open(){
return
}
let ps:PreparedStatement = db.prepareStatement("sql statement", values: [])
defer{
db.close()
}
do{
db.begin()
try ps.executeUpdate()
}catch DatabaseException.UpdateError(let err){
    db.rollback()
    print("Error while applying database operation: \(err)")
}
catch let err as NSError{
    db.rollback()
    print("Something went wrong: \(err)")
}
db.commit()
//NOTE
//db.begin(), db.rollback() and db.commit() are optional but if you use a begin, you must use either rollback or commit
```

### Executing a prepared statement for select
```swift
db.open()
let ps:PreparedStatement = db.prepareStatement("sql statement", values: [])
let rs = try ps.executeUpdate()
db.close()
```

### Retrieving values from a ResultSet
```swift
db.open()
let ps:PreparedStatement = db.prepareStatement("sql statement", values: [])
let rs:ResultSet = try ps.executeUpdate()
db.close()

// rs.next() will return true as long as there are more rows
// ResultSet allows you to retrieve column values either using the index or the name of the column
// The following values are supported:
// - bool <=> getBool(index:Int32)/getBool(index:String) will return true if the value is greater than 0, false otherwise 
// - String <=> getString(index:Int32)/getString(index:String)
// - Int32 <=> getInt(index:Int32)/getString(index:String)
// - Double <=> getDouble(index:Int32)/getDouble(index:String)
// - NSDate <=> getDate(index:Int32)/getDate(index:String)
while rs.next(){
    let col1 = rs.getString(1)
    let col2 = rs.getString("col2")
    ...
}
```

### Getting the type of a column from a ResultSet
```swift
// getType(index:Int32)/getType(index:String) <=> will return an int corresponding to the type
// Types are identified by the following constants:
// ResultSet.TYPE_INT = 1
// ResultSet.TYPE_FLOAT = 2
// ResultSet.TYPE_TEXT = 3
// ResultSet.TYPE_BLOB = 4
// ResultSet.TYPE_NIL = 5

let type = rs.getType(1)
```

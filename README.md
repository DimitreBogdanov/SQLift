# SQLite
SQLite is a simple and very basic swift library used as a wrapper for the c/c++ sqlite3 library.
This project is still work in progress and only supports basic features.

## Usage

### Note: this does not come with sqlite3 itself. Make sure it is included in your swift project otherwise the following code will not work.

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

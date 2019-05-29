let sqlite3 = require('sqlite3').verbose()
let config = require('config')

let db = new sqlite3.Database(config.DBHost)

let init = function () {
    db.run("CREATE TABLE if not exists user (" + 
        "id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "username TEXT UNIQUE NOT NULL," +
        "hashed_password TEXT NOT NULL" + ")",
        () => {
            if (process.env.NODE_ENV == 'test')
                db.run("DELETE from user")
        }
    )

    db.run("CREATE TABLE if not exists figure (" + 
        "id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "name TEXT NOT NULL," +
        "code TEXT NOT NULL," +
        "user_id INTEGER NOT NULL," + 
        "UNIQUE(name, user_id)" + ")",
        () => {
            if (process.env.NODE_ENV == 'test')
                db.run("DELETE from figure")
        }
    )
}

let reset = function () {
    db.run("DELETE from user")
    db.run("DELETE from figure")
} 

module.exports = {
    init: init,
    reset: reset,
    db: db
}

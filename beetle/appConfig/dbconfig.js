let sqlite3 = require('sqlite3').verbose()
let config = require('config')
let fs = require('fs')

if (process.env.NODE_ENV == 'test')
    fs.unlink(config.DBHost,    (err) => {
        if (err) return;
    })
let db = new sqlite3.Database(config.DBHost)

let init = function () {
    db.run("CREATE TABLE if not exists user (" + 
        "id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "username TEXT UNIQUE NOT NULL," +
        "hashed_password TEXT NOT NULL" + ")"
    )

    db.run("CREATE TABLE if not exists figure (" + 
        "id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "name TEXT NOT NULL," +
        "code TEXT NOT NULL," +
        "user_id INTEGER NOT NULL," + 
        "UNIQUE(name, user_id)" + ")"
    )
}

module.exports = {
    init: init,
    db: db
}

let sqlite3 = require('sqlite3').verbose()

let db = new sqlite3.Database('./sqlite.db')

let init = function () {
    db.run("CREATE TABLE if not exists user (" + 
        "id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "username TEXT," +
        "hashed_password TEXT" + ")"
    )

    db.run("CREATE TABLE if not exists figure (" + 
        "id INTEGER PRIMARY KEY AUTOINCREMENT," +
        "code TEXT," +
        "user_id INTEGER" + ")"
    )
}

module.exports = {
    init: init,
    db: db
}

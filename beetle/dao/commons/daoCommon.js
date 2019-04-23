const DB = require('../../config/dbconfig')
const DaoError = require('./daoError')

class DaoCommon {
    findAll(sqlRequest, sqlParams) {
        return new Promise(function (resolve, reject) {
            let statement = DB.db.prepare(sqlRequest)
            statement.all(sqlParams, function (err, rows) {
                if (err) {
                    reject(
                        new DaoError(500, "Internal server error")
                    )
                } else {
                    resolve(rows)
                }
            })
        })
    }

    findOne(sqlRequest, sqlParams) {
        return new Promise(function (resolve, reject) {
            let statement = DB.db.prepare(sqlRequest)
            statement.all(sqlParams, function (err, rows) {
                if (err) {
                    reject(
                        new DaoError(500, "Internal server error")
                    )
                } else if (rows === null || rows.length === 0) {
                    reject(
                        new DaoError(404, "Entity not found")
                    )
                } else {
                    let row = rows[0]
                    resolve(row)
                }
            })
        })
    }

    run(sqlRequest, sqlParams) {
        return new Promise(function (resolve, reject) {
            let statement = DB.db.prepare(sqlRequest)
            statement.run(sqlParams, function (err) {
                if (this.changes === 1) {
                    resolve(true)
                } else if (this.changes === 0) {
                    reject(
                        new DaoError(404, "Entity not found")
                    )
                } else {
                    reject(
                        new DaoError(500, "Internal server error")
                    )
                }
            })
        })
    }
}

module.exports = DaoCommon

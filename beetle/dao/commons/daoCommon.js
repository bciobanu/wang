// Load db configuration
const DB = require('../../config/dbconfig')

// Load DaoError entity
const DaoError = require('./daoError')

// Common methods for DAOs
class DaoCommon {
    /**
     * Find all entities that satisfy the SQL request
     * @param sqlRequest the SQL request
     * @param sqlParams values for the parameters from the sqlRequest
     * @returns the found entities
     */
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

    /**
     * Find the first entity that satisfies the SQL request
     * @param sqlRequest the SQL request
     * @param sqlParams values for the parameters from the sqlRequest
     * @returns the found entity
     */
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

    /**
     * Run a SQL request that modifies a table
     * @param sqlRequest the SQL request
     * @param sqlParams values for the parameters from the sqlRequest
     * @returns the id of the last inserted entity
     */
    run(sqlRequest, sqlParams) {
        return new Promise(function (resolve, reject) {
            let statement = DB.db.prepare(sqlRequest)
            statement.run(sqlParams, function (err) {
                if (this.changes === 1) {
                    resolve(this.lastID)
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

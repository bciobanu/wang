const Figure = require('../model/figure')
const daoCommon = require('./commons/daoCommon')

class FigureDao {
    constructor() {
        this.common = new daoCommon()
    }

    findById(id) {
        let sqlRequest = "SELECT * FROM figure WHERE id=$id"
        let sqlParams = {$id: id}

        return this.common.findOne(sqlRequest, sqlParams).then(row => 
            new Figure(row.id, row.code, row.user_id))
    }

    findAll(userId) {
        let sqlRequest = "SELECT * FROM figure WHERE user_id=$user_id"
        let sqlParams = {$user_id: userId}

        return this.common.findAll(sqlRequest, sqlParams).then(rows => {
            let figures = [];
            for (const row of rows) {
                figures.push(new Figure(row.id, row.code, row.user_id))
            }
            return figures
        })
    }

    update(Figure) {
        let sqlRequest = "UPDATE figure SET code=$code WHERE id=$id"
        let sqlParams = {$id: Figure.id, $code: Figure.code}

        return this.common.run(sqlRequest, sqlParams)
    }

    create(Figure) {
        let sqlRequest = "INSERT into figure (code, user_id) " +
            "VALUES ($code, $user_id)"
        let sqlParams = {$code: Figure.code, $user_id: Figure.userId}
        return this.common.run(sqlRequest, sqlParams)
    }

    deleteById(id) {
        let sqlRequest = "DELETE FROM figure WHERE id=$id"
        let sqlParams = {$id: id}
        return this.common.run(sqlRequest, sqlParams)
    }
}

module.exports = FigureDao

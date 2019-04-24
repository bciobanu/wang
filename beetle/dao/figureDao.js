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
            new Figure(row.id, row.name, row.code, row.user_id))
    }

    findAll(userId) {
        let sqlRequest = "SELECT id, name FROM figure WHERE user_id=$user_id"
        let sqlParams = {$user_id: userId}

        return this.common.findAll(sqlRequest, sqlParams).then(rows => {
            let figures = [];
            for (const row of rows) {
                figures.push(row)
            }
            return figures
        })
    }

    update(Figure) {
        let sqlRequest = "UPDATE figure SET name=$name, code=$code WHERE id=$id and user_id=$user_id"
        let sqlParams = {$id: Figure.id, $name: Figure.name, $code: Figure.code, $user_id: Figure.userId}

        return this.common.run(sqlRequest, sqlParams)
    }

    create(Figure) {
        let sqlRequest = "INSERT into figure (name, code, user_id) " +
            "VALUES ($name, $code, $user_id)"
        let sqlParams = {$name: Figure.name, $code: Figure.code, $user_id: Figure.userId}
        return this.common.run(sqlRequest, sqlParams)
    }

    deleteById(id, userId) {
        let sqlRequest = "DELETE FROM figure WHERE id=$id and user_id=$user_id"
        let sqlParams = {$id: id, $user_id: userId}
        return this.common.run(sqlRequest, sqlParams)
    }
}

module.exports = FigureDao

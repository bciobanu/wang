// Load Figure entity
const Figure = require('../model/figure')

// Load DAOs Common Methods
const daoCommon = require('./commons/daoCommon')

// Methods for Figure DAO
class FigureDao {
    constructor() {
        this.common = new daoCommon()
    }

    /**
     * Find the figure with the specified id
     * @param id the id of the figure we want to fine
     * @returns the found figure 
     */
    findById(id) {
        let sqlRequest = "SELECT * FROM figure WHERE id=$id"
        let sqlParams = {$id: id}

        return this.common.findOne(sqlRequest, sqlParams).then(row => 
            new Figure(row.id, row.name, row.code, row.user_id))
    }

    /**
     * Get all figures that correspond to a specified user
     * @param userId the id of the user
     * @returns a list of figures (only id and name fields)
     */
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

    /**
     * Update a figure
     * @param Figure a figure entity
     * @returns irrelevant
     */
    update(Figure) {
        let sqlRequest = "UPDATE figure SET name=IFNULL($name, name), code=IFNULL($code, code) WHERE id=$id and user_id=$user_id"
        let sqlParams = {$id: Figure.id, $name: Figure.name, $code: Figure.code, $user_id: Figure.userId}

        return this.common.run(sqlRequest, sqlParams)
    }

    /**
     * Create a figure
     * @param Figure a figure entity (without id field)
     * @returns id of the newly created Figure
     */
    create(Figure) {
        let sqlRequest = "INSERT into figure (name, code, user_id) " +
            "VALUES ($name, $code, $user_id)"
        let sqlParams = {$name: Figure.name, $code: Figure.code, $user_id: Figure.userId}
        return this.common.run(sqlRequest, sqlParams)
    }

    /**
     * Delete a figure
     * @param id the id of the Figure to be deleted
     * @param userId the id of the Figure's owner 
     * @returns irrelevant
     */
    deleteById(id, userId) {
        let sqlRequest = "DELETE FROM figure WHERE id=$id and user_id=$user_id"
        let sqlParams = {$id: id, $user_id: userId}
        return this.common.run(sqlRequest, sqlParams)
    }
}

module.exports = FigureDao

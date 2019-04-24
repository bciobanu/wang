const DaoError = require('../../dao/commons/daoError')

class ControllerCommon {
    findSuccess(res) {
        return (result) => {
            res.status(200)
            res.json(result)
        }
    }

    editSuccess(res) {
        return (result) => {
            res.status(201)
            res.json(result)
        }
    }

    serverError(res) {
        return (error) => {
            res.status(500)
            res.json(error)
        }
    }

    findError(res) {
        return (error) => {
            res.status(404)
            res.json(error)
        }
    }

    alreadyExistsError(res) {
        return (result) => {
            res.status(409)
            res.json(new DaoError(409, "Entity already exists"))
        }
    }
}

module.exports = ControllerCommon

const DaoError = require('../../dao/commons/daoError')

class ControllerCommon {
    findSuccess(res, serializer) {
        return (result) => {
            res.status(200)
            res.json(serializer ? serializer(result) : result)
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

    unauthorizedError(res) {
        return () => {
            res.status(401)
            res.json(new DaoError(401, "Unauthorized"))
        }
    }

    authorized(res) {
        return (token) => {
            res.status(200)
            res.json({auth: true, token: token})
        }
    }
}

module.exports = ControllerCommon

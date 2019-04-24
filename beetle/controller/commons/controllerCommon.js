// Load DaoError entity
const DaoError = require('../../dao/commons/daoError')

// Common methods for controllers
class ControllerCommon {
    /**
     * returns a callback for the result from a successful find SQL request
     * in wich sets the status code and body of the http response 
     * @param res the http response
     * @param serializer optional parameter for serializing the result into a JSON  
     * @returns the callback
     */
    findSuccess(res, serializer) {
        return (result) => {
            res.status(200)
            res.json(serializer ? serializer(result) : result)
        }
    }

    /**
     * returns a callback for the result from a successful edit SQL request
     * in wich sets the status code and body of the http response 
     * @param res the http response  
     * @returns the callback
     */
    editSuccess(res) {
        return (result) => {
            res.status(201)
            res.json(result)
        }
    }

    /**
     * returns a callback for the result from an unsuccessful SQL request
     *  caused by a server error
     * in wich sets the status code and body of the http response 
     * @param res the http response  
     * @returns the callback
     */
    serverError(res) {
        return (error) => {
            res.status(500)
            res.json(error)
        }
    }

    /**
     * returns a callback for the result from an unsuccessful SQL request
     *  caused by a missing entity
     * in wich sets the status code and body of the http response 
     * @param res the http response  
     * @returns the callback
     */
    findError(res) {
        return (error) => {
            res.status(404)
            res.json(error)
        }
    }

    /**
     * returns a callback that sets the status code and body of the http response
     * when an unauthorized request is made 
     * @param res the http response  
     * @returns the callback
     */
    unauthorizedError(res) {
        return () => {
            res.status(401)
            res.json(new DaoError(401, "Unauthorized"))
        }
    }

    /**
     * returns a callback that sets the status code and body of the http response
     *  putting the generated token into the response body
     * when an authentication is made 
     * @param res the http response  
     * @returns the callback
     */
    authorized(res) {
        return (token) => {
            res.status(200)
            res.json({auth: true, token: token})
        }
    }
}

module.exports = ControllerCommon

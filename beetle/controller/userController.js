// Load User DAO
const UserDao = require('../dao/userDao')

// Load common methods for controller
const ControllerCommon = require('./commons/controllerCommon')

// Load User entity
const User = require('../model/user')

// create a serializer factory object
const SerializerFactory = require('../helpers/serializerFactory')
const serializerFactory = new SerializerFactory()

class UserController {
    constructor() {
        this.common = new ControllerCommon()
        this.userDao = new UserDao()
    }

    /**
     * find a user by the specified id from the request and return it
     * in the response body without the password hash
     * @param req the http request 
     * @param res the http response
     */
    findById(req, res) {
        let id = req.userId
        this.userDao.findById(id)
            .then(this.common.findSuccess(res, serializerFactory.userSerializer()))
            .catch(this.common.findError(res))
    }
}

module.exports = UserController

const UserDao = require('../dao/userDao')
const ControllerCommon = require('./commons/controllerCommon')
const User = require('../model/user')

const SerializerFactory = require('../helpers/serializerFactory')
const serializerFactory = new SerializerFactory()

class UserController {
    constructor() {
        this.common = new ControllerCommon()
        this.userDao = new UserDao()
    }

    findById(req, res) {
        let id = req.userId
        this.userDao.findById(id)
            .then(this.common.findSuccess(res, serializerFactory.userSerializer()))
            .catch(this.common.findError(res))
    }
}

module.exports = UserController

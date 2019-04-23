const UserDao = require('../dao/userDao')
const ControllerCommon = require('./commons/controllerCommon')
const User = require('../model/user')

class UserController {
    constructor() {
        this.common = new ControllerCommon()
        this.userDao = new UserDao()
    }

    findById(req, res) {
        let id = req.params.id
        this.userDao.findById(id)
            .then(this.common.findSuccess(res))
            .catch(this.common.findError(res))
    }

    findAll(req, res) {
        this.userDao.findAll()
            .then(this.common.findSuccess(res))
            .catch(this.common.findError(res))
    }

    update(req, res) {
        let user = new User(req.params.id, req.body.username, req.body.hashed_password)
        this.userDao.update(user)
            .then(this.common.editSuccess(res))
            .catch(this.common.serverError(res))
    }

    create(req, res) {
        let user = new User()
        user.username = req.body.username
        user.hashedPassword = req.body.hashed_password
        return this.userDao.create(user)
            .then(this.common.editSuccess(res))
            .catch(this.common.serverError(res))
    }
}

module.exports = UserController

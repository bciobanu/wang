const UserDao = require('../dao/userDao')
const ControllerCommon = require('./commons/controllerCommon')
const User = require('../model/user')

const authconfig = require('../config/authconfig')

const jwt = require('jsonwebtoken')

class AuthController {
    constructor() {
        this.common = new ControllerCommon()
        this.userDao = new UserDao()
    }

    register(req, res) {
        this.userDao.findByUsername(req.body.username)
            .then(this.common.alreadyExistsError(res))
            .catch(error => {
                let user = new User()
                user.username = req.body.username
                user.hashedPassword = req.body.hashed_password
                this.userDao.create(user)
                    .then(function (result) {
                        let token = jwt.sign({id: result}, 
                            authconfig.secret, 
                            {expiresIn: 86400}
                        )
                        res.status(200).json({auth: true, token: token})
                    })
                    .catch(this.common.serverError(res))
            })
    }
}

module.exports = AuthController

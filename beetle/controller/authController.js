const UserDao = require('../dao/userDao')
const ControllerCommon = require('./commons/controllerCommon')
const User = require('../model/user')

const authconfig = require('../config/authconfig')

const jwt = require('jsonwebtoken')
const bcrypt = require('bcryptjs')

class AuthController {
    constructor() {
        this.common = new ControllerCommon()
        this.userDao = new UserDao()
    }

    register(req, res) {
        let hashedPassword = bcrypt.hashSync(req.body.password, 8)
        let user = new User()
        user.username = req.body.username
        user.hashedPassword = hashedPassword
        this.userDao.create(user)
            .then(result => {
                let token = jwt.sign({id: result}, 
                    authconfig.secret, 
                    {expiresIn: 86400}
                )
                this.common.authorized(res)(token)
            })
            .catch(this.common.serverError(res))
    }

    login(req, res) {
        this.userDao.findByUsername(req.body.username)
            .then(user => {
                let passwordIsValid = bcrypt.compareSync(req.body.password, user.hashedPassword)
                if (!passwordIsValid) {
                    this.common.unauthorizedError(res)()
                } else {
                    let token = jwt.sign({id: user.id}, 
                        authconfig.secret, 
                        {expiresIn: 86400}
                    )
                    this.common.authorized(res)(token)
                }
            })
            .catch(this.common.serverError(res))
    }
}

module.exports = AuthController

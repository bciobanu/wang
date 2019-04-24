// Load User DAO
const UserDao = require('../dao/userDao')

// Load common methods for controller
const ControllerCommon = require('./commons/controllerCommon')

// Load User entity
const User = require('../model/user')

// Load auth configuration
const authconfig = require('../config/authconfig')

// Load JSON Web Token
const jwt = require('jsonwebtoken')

// Load Bcrypt for hashing
const bcrypt = require('bcryptjs')

// Controller for authentication methods
class AuthController {
    constructor() {
        this.common = new ControllerCommon()
        this.userDao = new UserDao()
    }

    /**
     * register a new user and if successful add to the response body the generated token  
     * @param req the http request 
     * @param res the http response
     */
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

    /**
     * log in an existing user and if successful add to the response body the generated token  
     * @param req the http request 
     * @param res the http response
     */
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

// Load modules
const express = require('express')
const router = express.Router()

// Load controller
const AuthController = require('../../controller/authController')
const authController = new AuthController()

// Load validator
const ValidatorFactory = require('../../helpers/validatorFactory')
const validatorFactory = new ValidatorFactory()

/** 
 * Auth routes
 */ 

router.post('/register', validatorFactory.userAuthValidator(), function (req, res) {
    authController.register(req, res)
})

router.post('/login', validatorFactory.userAuthValidator(), function (req, res) {
    authController.login(req, res)
})

module.exports = router

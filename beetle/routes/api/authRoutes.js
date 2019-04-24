const express = require('express')
const router = express.Router()

const AuthController = require('../../controller/authController')
const authController = new AuthController()

const ValidatorFactory = require('../../helpers/validatorFactory')
const validatorFactory = new ValidatorFactory()

router.post('/register', validatorFactory.userAuthValidator(), function (req, res) {
    authController.register(req, res)
})

router.post('/login', validatorFactory.userAuthValidator(), function (req, res) {
    authController.login(req, res)
})

module.exports = router

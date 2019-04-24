const express = require('express')
const router = express.Router()

const AuthController = require('../../controller/authController')
const authController = new AuthController()

router.post('/register', function (req, res) {
    authController.register(req, res)
})

router.post('/login', function (req, res) {
    authController.login(req, res)
})

module.exports = router

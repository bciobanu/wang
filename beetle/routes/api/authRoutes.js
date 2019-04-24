const express = require('express')
const router = express.Router()

const AuthController = require('../../controller/authController')
const authController = new AuthController()

const jwt = require('jsonwebtoken')
const bcrypt = require('bcryptjs')

router.post('/register', function (req, res) {
    req.body.hashed_password = bcrypt.hashSync(req.body.password, 8)
    authController.register(req, res)
})

module.exports = router

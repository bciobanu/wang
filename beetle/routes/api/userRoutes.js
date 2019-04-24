// Load modules
const express = require('express')
const router = express.Router()

// Load controller
const UserController = require('../../controller/userController')
const userController = new UserController()

// Load token verifier
const verifyToken = require('../../helpers/verifyToken')

/**
 * User entity routes
 */

router.get('/', verifyToken, function (req, res) {
    userController.findById(req, res)
})

module.exports = router

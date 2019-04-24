const express = require('express')
const router = express.Router()

const UserController = require('../../controller/userController')
const userController = new UserController()

const verifyToken = require('../../helpers/verifyToken')

router.get('/', verifyToken, function (req, res) {
    userController.findById(req, res)
})

module.exports = router

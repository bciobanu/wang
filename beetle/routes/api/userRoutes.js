const express = require('express')
const router = express.Router()

const UserController = require('../../controller/userController')
const userController = new UserController()

router.get('/:id', function (req, res) {
    userController.findById(req, res)
})

router.get('/', function (req, res) {
    userController.findAll(req, res)
})

router.put('/:id', function (req, res) {
    userController.update(req, res)
})

router.post('/', function (req, res) {
    userController.create(req, res)
})

module.exports = router

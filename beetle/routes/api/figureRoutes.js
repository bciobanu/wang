const express = require('express')
const router = express.Router()

const FigureController = require('../../controller/figureController')
const figureController = new FigureController()

const verifyToken = require('../../helpers/verifyToken')

const ValidatorFactory = require('../../helpers/validatorFactory')
const validatorFactory = new ValidatorFactory()

router.get('/', verifyToken, function (req, res) {
    figureController.findAll(req, res)
})

router.get('/:id', verifyToken, function (req, res) {
    figureController.findById(req, res)
})

router.put('/:id', verifyToken, validatorFactory.figureValidator(), function (req, res) {
    figureController.update(req, res)
})

router.post('/', verifyToken, validatorFactory.figureValidator(), function (req, res) {
    figureController.create(req, res)
})

router.delete('/:id', verifyToken, function (req, res) {
    figureController.delete(req, res)
})

module.exports = router

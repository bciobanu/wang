const express = require('express')
const router = express.Router()

const FigureController = require('../../controller/figureController')
const figureController = new FigureController()

const verifyToken = require('../../controller/commons/verifyToken')

router.get('/', verifyToken, function (req, res) {
    figureController.findAll(req, res)
})

router.get('/:id', verifyToken, function (req, res) {
    figureController.findById(req, res)
})

router.put('/:id', verifyToken, function (req, res) {
    figureController.update(req, res)
})

router.post('/', verifyToken, function (req, res) {
    figureController.create(req, res)
})

router.delete('/:id', verifyToken, function (req, res) {
    figureController.delete(req, res)
})

module.exports = router

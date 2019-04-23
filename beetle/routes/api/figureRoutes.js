const express = require('express')
const router = express.Router()

const FigureController = require('../../controller/figureController')
const figureController = new FigureController()

router.get('/:id', function (req, res) {
    figureController.findById(req, res)
})

router.get('/from/:user_id', function (req, res) {
    figureController.findAll(req, res)
})

router.put('/:id', function (req, res) {
    figureController.update(req, res)
})

router.post('/', function (req, res) {
    figureController.create(req, res)
})

router.delete('/:id', function (req, res) {
    figureController.delete(req, res)
})

module.exports = router

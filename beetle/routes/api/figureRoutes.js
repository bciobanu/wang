const express = require('express')
const router = express.Router()

const FigureController = require('../../controller/figureController')
const figureController = new FigureController()

const verifyToken = require('../../helpers/verifyToken')

const ValidatorFactory = require('../../helpers/validatorFactory')
const validatorFactory = new ValidatorFactory()

const napocaConfig = require('../../config/napocaconfig')
const napoca_client = require('napoca-client')
const napocaClient = new napoca_client.NapocaClient("localhost:" + napocaConfig.port)

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

router.post('/compile', function (req, res) {
    codeToCompile = (req.body.code ? String(req.body.code) : "")
    napocaClient.requestParse(codeToCompile, 
        compiled => {
            res.status(200).json({compiled: compiled})
        },
        err => {
            res.status(400).json({errors: err})
        })
})

module.exports = router

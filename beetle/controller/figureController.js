const FigureDao = require('../dao/figureDao')
const ControllerCommon = require('./commons/controllerCommon')
const Figure = require('../model/figure')

class FigureController {
    constructor() {
        this.common = new ControllerCommon()
        this.figureDao = new FigureDao()
    }

    findById(req, res) {
        let id = req.params.id
        this.figureDao.findById(id)
            .then(this.common.findSuccess(res))
            .catch(this.common.findError(res))
    }

    findAll(req, res) {
        let userId = req.params.user_id
        this.figureDao.findAll(userId)
            .then(this.common.findSuccess(res))
            .catch(this.common.findError(res))
    }

    update(req, res) {
        let figure = new Figure(req.params.id, req.body.code, req.body.user_id)
        return this.figureDao.update(figure)
            .then(this.common.editSuccess(res))
            .catch(this.common.serverError(res))
    }

    create(req, res) {
        let figure = new Figure()
        figure.code = req.body.code
        figure.userId = req.body.user_id
        return this.figureDao.create(figure)
            .then(this.common.editSuccess(res))
            .catch(this.common.serverError(res))
    }

    delete(req, res) {
        let id = req.params.id
        return this.figureDao.deleteById(id)
            .then(this.common.findSuccess(res))
            .catch(this.common.findError(res))
    }
}

module.exports = FigureController

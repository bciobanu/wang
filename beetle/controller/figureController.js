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
        let userId = req.userId
        this.figureDao.findById(id)
            .then(figure => {
                if (figure.userId !== userId)
                    this.common.unauthorizedError(res)()
                else
                    this.common.findSuccess(res)(figure)
            })
            .catch(this.common.findError(res))
    }

    findAll(req, res) {
        let userId = req.userId
        this.figureDao.findAll(userId)
            .then(this.common.findSuccess(res))
            .catch(this.common.findError(res))
    }

    update(req, res) {
        let figure = new Figure(req.params.id, req.body.name, req.body.code, req.userId)
        return this.figureDao.update(figure)
            .then(this.common.editSuccess(res))
            .catch(this.common.serverError(res))
    }

    create(req, res) {
        let figure = new Figure()
        figure.name = req.body.name
        figure.code = req.body.code
        figure.userId = req.userId
        return this.figureDao.create(figure)
            .then(this.common.editSuccess(res))
            .catch(this.common.serverError(res))
    }

    delete(req, res) {
        let id = req.params.id
        return this.figureDao.deleteById(id, req.userId)
            .then(this.common.findSuccess(res))
            .catch(this.common.findError(res))
    }
}

module.exports = FigureController

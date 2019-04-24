// Load Figure DAO
const FigureDao = require('../dao/figureDao')

// Load common methods for controller
const ControllerCommon = require('./commons/controllerCommon')

// Load Figure entity
const Figure = require('../model/figure')

// Controller for figure processing methods
class FigureController {
    constructor() {
        this.common = new ControllerCommon()
        this.figureDao = new FigureDao()
    }

    /**
     * find a figure of the authenticated user and if successful add to the response body the figure  
     * @param req the http request 
     * @param res the http response
     */
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

    /**
     * find all figure of the authenticated user
     * and if successful add to the response body the figures (array, only id and name)  
     * @param req the http request 
     * @param res the http response
     */
    findAll(req, res) {
        let userId = req.userId
        this.figureDao.findAll(userId)
            .then(this.common.findSuccess(res))
            .catch(this.common.findError(res))
    }

    /**
     * edit a figure of the authenticated user  
     * @param req the http request 
     * @param res the http response
     */
    update(req, res) {
        let figure = new Figure(req.params.id, req.body.name, req.body.code, req.userId)
        return this.figureDao.update(figure)
            .then(this.common.editSuccess(res))
            .catch(this.common.serverError(res))
    }

    /**
     * create a figure for the authenticated user  
     * @param req the http request 
     * @param res the http response
     */
    create(req, res) {
        let figure = new Figure()
        figure.name = req.body.name
        figure.code = req.body.code
        figure.userId = req.userId
        return this.figureDao.create(figure)
            .then(this.common.editSuccess(res))
            .catch(this.common.serverError(res))
    }

    /**
     * delete a figure of the authenticated user  
     * @param req the http request 
     * @param res the http response
     */
    delete(req, res) {
        let id = req.params.id
        return this.figureDao.deleteById(id, req.userId)
            .then(this.common.findSuccess(res))
            .catch(this.common.findError(res))
    }
}

module.exports = FigureController

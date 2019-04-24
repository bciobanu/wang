const validator = require('validator')

class ValidatorFactory {
    userAuthValidator() {
        return (req, res, next) => {
            if (!req.body.username || !req.body.password ||
                    validator.isEmpty(req.body.username) ||
                    validator.isEmpty(req.body.password) ||
                    !validator.isAlphanumeric(req.body.username) ||
                    String(req.body.password).length < 6) {
                return res.status(400).json({message: "Invalid arguments"})
            }
            next()
        }
    }

    figureValidator() {
        return (req, res, next) => {
            if (req.body.name != null && 
                    (validator.isEmpty(req.body.name) || 
                    !validator.isAlphanumeric(String(req.body.name).replace(/\s+/g, '')))) {
                return res.status(400).json({message: "Invalid arguments"})
            }
            next()
        }
    }
}

module.exports = ValidatorFactory

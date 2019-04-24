// Load JSON Web Token
const jwt = require('jsonwebtoken')

// Load auth configuration
const authconfig = require('../config/authconfig')

// middleware method that verifies a token and identifies its owner
function verifyToken(req, res, next) {
    let token = req.headers['x-access-token']
    if (!token)
        return res.status(401).json({auth: false, message: 'No token'})
    jwt.verify(token, authconfig.secret, (err, decoded) => {
        if (err)
            return res.status(401).json({auth: false, message: 'Not authorized'})
        req.userId = decoded.id
        next()
    })
}

module.exports = verifyToken

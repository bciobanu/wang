const express = require('express')
const app = express()
const bodyParser = require('body-parser')

const DB = require('./config/dbconfig')
DB.init()

app.listen(3000, () => {
    console.log('Server is up and listening on 3000')
})

const allowCrossDomain = function(req, res, next) {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', '*');
    res.header('Access-Control-Allow-Headers', '*');
    next();
}
app.use(allowCrossDomain)

app.use(bodyParser.urlencoded({extended: false}))
app.use(bodyParser.json())

const REST_API_ROOT = '/api'
app.use(REST_API_ROOT, require('./routes/router'))

module.exports = app

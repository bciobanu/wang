const express = require('express');
const router = express.Router();

/* API routes */
router.use('/user', require('./api/userRoutes'))
router.use('/figure', require('./api/figureRoutes'))
router.use('/auth', require('./api/authRoutes'))

module.exports = router
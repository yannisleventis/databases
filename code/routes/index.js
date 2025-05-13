const express = require('express');
const router  = express.Router();

router.get('/', (req, res) => res.redirect('/festivals'));
router.use('/festivals', require('./festivalRoutes'));
router.use('/queries', require('./queryRoutes'));

module.exports = router;

const express = require('express');
const router = express.Router();
const festivalController = require('../controllers/festivalController');

router.get('/', festivalController.getAllFestivals);

module.exports = router;
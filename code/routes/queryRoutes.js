const express = require('express');
const router  = express.Router();
const queryController = require('../controllers/queryController');

// list page with the drop-down
router.get('/',  queryController.listQueries);
router.post('/',       queryController.pickQuery);
router.get('/:id', queryController.runQuery);       // /queries/3 → execute query #3

module.exports = router;



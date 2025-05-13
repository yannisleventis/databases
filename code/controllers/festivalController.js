const db = require('../utils/db');

exports.getAllFestivals = async (req, res, next) => {
  try {
    const [festivals] = await db.query('SELECT * FROM Festival');
    res.render('festivals', { festivals });
  } catch (err) {
    next(err);
  }
};
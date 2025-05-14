// controllers/queryController.js
// Loads .sql files from project-root/sql/ and executes them on demand
const path = require('path');
const fs   = require('fs/promises');
const db   = require('../utils/db');

// Directory where you store .sql files (e.g., project-root/sql/Q01.sql)
const queriesDir = path.join(__dirname, '..', 'sql');

// Helper: read all .sql files and build an array: [{ slug, file, title, sql }]
async function loadQueries() {
  const files = (await fs.readdir(queriesDir))
    .filter(f => f.endsWith('.sql'))
    .sort((a, b) => a.localeCompare(b, undefined, { numeric: true }));

  return Promise.all(
    files.map(async file => {
      const sqlPath = path.join(queriesDir, file);
      const sql     = await fs.readFile(sqlPath, 'utf8');

      const slug  = path.basename(file, '.sql');      //  Q01   Q02 …
      let   title = slug;                             // default title: Q01
      const first = sql.split('\n')[0].trim();        // first line comment?
      if (first.startsWith('--')) title = first.replace(/^--\s*/, '');

      return { slug, file, title, sql };
    })
  );
}

// GET /queries  → list available scripts
exports.listQueries = async (req, res, next) => {
  try {
    const queries = await loadQueries();
    res.render('queries', { queries });
  } catch (err) {
    next(err);
  }
};

// GET /queries/:slug  → run selected script
exports.runQuery = async (req, res, next) => {
  try {
    const slug    = req.params.slug;                  // Q01, Q02 …
    const queries = await loadQueries();
    const q       = queries.find(q => q.slug === slug);
    if (!q) return res.status(404).render('error', { error: 'Unknown query file' });

    const statements = q.sql.split(/;\s*(?:\r?\n|$)/).filter(s => s.trim());
    let rows = [];
    for (const stmt of statements) {
      if (!stmt.trim().replace(/^--.*$/gm, '').trim()) continue;
      const [r] = await db.query(stmt);
      rows = r;                                       // keep last resultset
    }
    res.render('queryResult', { query: q, rows });
  } catch (err) {
    next(err);
  }
};

// POST /queries  → redirect
exports.pickQuery = (req, res) => {
  const slug = req.body.querySlug;
  if (!slug) return res.redirect('/queries');
  res.redirect(`/queries/${slug}`);
};

  
// controllers/queryController.js
// Loads .sql files from project-root/sql/ and executes them on demand
const path = require('path');
const fs   = require('fs/promises');
const db   = require('../utils/db');

// Directory where you store .sql files (e.g., project-root/sql/query1.sql)
const queriesDir = path.join(__dirname, '..', 'sql');

// Helper: read all .sql files and build an array: [{ id, file, title, sql }]
async function loadQueries() {
  const files = (await fs.readdir(queriesDir))
    .filter(f => f.endsWith('.sql'))
    .sort((a, b) => a.localeCompare(b));

  let idx = 0;
  return Promise.all(
    files.map(async file => {
      const sqlPath = path.join(queriesDir, file);
      const sql     = await fs.readFile(sqlPath, 'utf8');

      // Use first line comment as the title, fallback to filename
      let title = file.replace(/\.sql$/i, '').replace(/[_-]/g, ' ');
      const firstLine = sql.split('\n')[0].trim();
      if (firstLine.startsWith('--')) {
        title = firstLine.replace(/^--\s*/, '');
      }

      return { id: ++idx, file, title, sql };
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

// GET /queries/:id  → run selected script and show results
exports.runQuery = async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    const queries = await loadQueries();
    const q = queries.find(q => q.id === id);
    if (!q) return res.status(404).render('error', { error: 'Unknown query id' });

    // new
    const statements = q.sql.split(/;\s*$/m).filter(s => s.trim());
    let rows = [];
    for (const stmt of statements) {
      // Ignore comments-only chunks
      if (!stmt.trim().replace(/^--.*$/gm, '').trim()) continue;
      const [r] = await db.query(stmt);
      rows = r;                     // keep last resultset for display
    }
    res.render('queryResult', { query: q, rows });
  } catch (err) {
    next(err);
  }
};


// controllers/queryController.js 
exports.pickQuery = async (req, res) => {
    const id = Number(req.body.queryId);
    if (!id) return res.redirect('/queries');   // safety
    res.redirect(`/queries/${id}`);
  };
  
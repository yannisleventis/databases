const express = require('express');
const path = require('path');
const routes = require('./routes');

const app = express();

// view engine setup
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// static files
app.use(express.static(path.join(__dirname, 'public')));

// body parsers
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

// Logging middleware
app.use((req, res, next) => {
  console.log(req.method, req.url);
  next();
});

app.get('/ping', (req, res) => res.send('pong'));

// routes
app.use('/', routes);

// 404 handler - AFTER routes
app.use((req, res) => {
  res.status(404).render('error', { error: 'Page not found' });
});

// error handler
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).render('error', { error: err.message });
});

app.listen(3000, () => console.log('Server listening on http://localhost:3000'));
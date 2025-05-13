const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  port: 3307,
  host: 'localhost',
  user: 'root',
  password: '123456',
  database: 'musicfestival',
  waitForConnections: true,
  connectionLimit: 10,
});

module.exports = pool;
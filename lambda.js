const serverless = require('serverless-http');
const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const path = require('path');

const app = express();

// PostgreSQL connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// Body parser
app.use(bodyParser.json());

// Static files (you can skip this in Lambda or use S3)
app.use(express.static(path.join(__dirname, 'public')));
app.use('/input', express.static(path.join(__dirname, 'input')));
app.use('/output', express.static(path.join(__dirname, 'output')));

// Initialize DB
async function initDB() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS history (
      id SERIAL PRIMARY KEY,
      data JSONB NOT NULL,
      created_at TIMESTAMPTZ DEFAULT NOW()
    );
  `);
}
initDB().catch(console.error);

// Routes
app.post('/save-history', async (req, res) => {
  const json = req.body;
  if (!json || Object.keys(json).length === 0) return res.status(400).send('Cannot save empty history');

  try {
    await pool.query('INSERT INTO history (data) VALUES ($1)', [json]);
    res.status(200).send('Saved');
  } catch (err) {
    console.error(err);
    res.status(500).send('Failed to save history');
  }
});

app.get('/get-history', async (req, res) => {
  try {
    const result = await pool.query('SELECT data FROM history ORDER BY created_at DESC LIMIT 1');
    res.json(result.rows.length > 0 ? result.rows[0].data : {});
  } catch (err) {
    console.error(err);
    res.status(500).send('Failed to fetch history');
  }
});

// Export Lambda handler
module.exports.handler = serverless(app);

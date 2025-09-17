const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const path = require('path');

const app = express();
const PORT = 3000;

// PostgreSQL connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL, // set in docker-compose
});

// Body parser
app.use(bodyParser.json());

// ✅ Serve static folders: public, input, output
app.use(express.static(path.join(__dirname, 'public')));  // for index.html, JS, CSS
app.use('/input', express.static(path.join(__dirname, 'input')));  // for /input/*.json
app.use('/output', express.static(path.join(__dirname, 'output'))); // for /output/*.json if needed

// ✅ API routes first
app.post('/save-history', async (req, res) => {
  try {
    const json = req.body;
    if (Object.keys(json).length === 0) {
      return res.status(400).send('Cannot save empty history');
    }
    await pool.query('INSERT INTO history (data) VALUES ($1)', [json]);
    console.log('History successfully saved.');
    res.status(200).send('Saved');
  } catch (err) {
    console.error('Error saving history:', err);
    res.status(500).send('Failed to save history');
  }
});

app.get('/get-history', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT data FROM history ORDER BY created_at DESC LIMIT 1'
    );
    res.json(result.rows.length > 0 ? result.rows[0].data : {});
  } catch (err) {
    console.error('Error retrieving history:', err);
    res.status(500).send('Failed to fetch history');
  }
});

// Root route -> index.html
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});

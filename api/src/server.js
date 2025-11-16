import 'dotenv/config';
import app from './app.js';
import pool from './config/db.js';

const PORT = process.env.PORT || 3000;

const startServer = async () => {
  try {
    await pool.query('SELECT 1');
    console.log('Connected to MySQL database');

    app.listen(PORT, () => {
      console.log(`Server listening on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error('Failed to initialize application', error);
    process.exit(1);
  }
};

startServer();

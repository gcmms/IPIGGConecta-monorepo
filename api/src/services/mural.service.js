import pool from '../config/db.js';

const normalizeRows = (rows) => (Array.isArray(rows) ? rows : []);

export const getMuralItems = async () => {
  const [rows] = await pool.execute(
    'SELECT id, title, subtitle, publish_date, link, created_at, updated_at FROM mural ORDER BY publish_date DESC'
  );
  return normalizeRows(rows);
};

export const createMuralItem = async ({ title, subtitle, publish_date, link }) => {
  const cleanLink = link?.trim() || null;

  const [insertResult] = await pool.execute(
    `
      INSERT INTO mural (title, subtitle, publish_date, link)
      VALUES (?, ?, ?, ?)
    `,
    [title.trim(), subtitle.trim(), publish_date, cleanLink]
  );

  const insertedId = insertResult.insertId;

  const [rows] = await pool.execute(
    'SELECT id, title, subtitle, publish_date, link, created_at, updated_at FROM mural WHERE id = ?',
    [insertedId]
  );

  return normalizeRows(rows)[0];
};

export const deleteMuralItem = async (id) => {
  const [result] = await pool.execute('DELETE FROM mural WHERE id = ?', [id]);
  return result.affectedRows > 0;
};

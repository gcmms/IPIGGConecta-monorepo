import pool from '../config/db.js';

const normalizeRows = (rows) => (Array.isArray(rows) ? rows : []);
const buildHttpError = (message, statusCode) => {
  const error = new Error(message);
  error.status = statusCode;
  return error;
};
const mapUserForResponse = (row) => ({
  id: row.id,
  first_name: row.first_name,
  last_name: row.last_name,
  email: row.email,
  phone: row.phone,
  birth_date: row.birth_date,
  role: row.role || 'Membro'
});

export const listMembers = async () => {
  const [rows] = await pool.execute(
    `
      SELECT id, first_name, last_name, email, phone, birth_date, role
      FROM users
      ORDER BY first_name ASC, last_name ASC
    `
  );

  return normalizeRows(rows);
};

export const updateMemberRole = async ({ userId, role }) => {
  const [result] = await pool.execute(
    'UPDATE users SET role = ? WHERE id = ?',
    [role, userId]
  );

  if (result.affectedRows === 0) {
    throw buildHttpError('Usuário não encontrado.', 404);
  }

  const [rows] = await pool.execute(
    'SELECT id, first_name, last_name, email, phone, birth_date, role FROM users WHERE id = ?',
    [userId]
  );

  const normalizedRows = normalizeRows(rows);
  return mapUserForResponse(normalizedRows[0]);
};

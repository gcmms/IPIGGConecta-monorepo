import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import pool from '../config/db.js';

const JWT_SECRET = process.env.JWT_SECRET;

if (!JWT_SECRET) {
  throw new Error('JWT_SECRET is not defined');
}

const mapUserForResponse = (row) => ({
  id: row.id,
  first_name: row.first_name,
  last_name: row.last_name,
  email: row.email,
  phone: row.phone,
  birth_date: row.birth_date,
  role: row.role || 'Membro'
});

const buildHttpError = (message, statusCode) => {
  const error = new Error(message);
  error.status = statusCode;
  return error;
};

export const registerUser = async ({
  first_name,
  last_name,
  birth_date,
  email,
  phone,
  password,
  role
}) => {
  const normalizedEmail = email.trim().toLowerCase();
  const normalizedRole =
    typeof role === 'string' && role.toLowerCase() === 'administrador'
      ? 'Administrador'
      : 'Membro';

  const [existingUserRows] = await pool.execute(
    'SELECT 1 FROM users WHERE email = ? LIMIT 1',
    [normalizedEmail]
  );

  if (Array.isArray(existingUserRows) && existingUserRows.length > 0) {
    throw buildHttpError('E-mail já cadastrado.', 409);
  }

  const passwordHash = await bcrypt.hash(password, 10);

  const insertQuery = `
    INSERT INTO users (first_name, last_name, birth_date, email, phone, role, password_hash)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `;

  const values = [
    first_name.trim(),
    last_name.trim(),
    birth_date,
    normalizedEmail,
    phone?.trim() || null,
    normalizedRole,
    passwordHash
  ];

  const [insertResult] = await pool.execute(insertQuery, values);
  const insertedId = insertResult.insertId;

  const [rows] = await pool.execute(
    'SELECT id, first_name, last_name, email, phone, birth_date, role FROM users WHERE id = ?',
    [insertedId]
  );

  const normalizedRows = Array.isArray(rows) ? rows : [];
  return mapUserForResponse(normalizedRows[0]);
};

export const loginUser = async ({ email, password }) => {
  const normalizedEmail = email.trim().toLowerCase();

  const [rows] = await pool.execute(
    'SELECT * FROM users WHERE email = ? LIMIT 1',
    [normalizedEmail]
  );

  const normalizedRows = Array.isArray(rows) ? rows : [];
  const user = normalizedRows[0];

  if (!user) {
    throw buildHttpError('Credenciais inválidas.', 401);
  }

  const passwordIsValid = await bcrypt.compare(password, user.password_hash);

  if (!passwordIsValid) {
    throw buildHttpError('Credenciais inválidas.', 401);
  }

  const tokenPayload = {
    id: user.id,
    first_name: user.first_name,
    last_name: user.last_name,
    email: user.email,
    role: user.role || 'Membro'
  };

  const token = jwt.sign(tokenPayload, JWT_SECRET, { expiresIn: '7d' });

  return {
    token,
    user: mapUserForResponse(user)
  };
};

export const getUserById = async (userId) => {
  const [rows] = await pool.execute(
    'SELECT id, first_name, last_name, email, phone, birth_date, role FROM users WHERE id = ? LIMIT 1',
    [userId]
  );

  const normalizedRows = Array.isArray(rows) ? rows : [];
  const user = normalizedRows[0];

  if (!user) {
    throw buildHttpError('Usuário não encontrado.', 404);
  }

  return mapUserForResponse(user);
};

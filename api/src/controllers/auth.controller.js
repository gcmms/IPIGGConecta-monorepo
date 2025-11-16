import {
  registerUser,
  loginUser,
  getUserById
} from '../services/auth.service.js';

const requiredRegisterFields = [
  'first_name',
  'last_name',
  'birth_date',
  'email',
  'password'
];

const validateRequiredFields = (body, fields) => {
  return fields.filter((field) => {
    const value = body[field];
    return value === undefined || value === null || String(value).trim() === '';
  });
};

export const handleRegister = async (req, res) => {
  const missingFields = validateRequiredFields(req.body, requiredRegisterFields);

  if (missingFields.length > 0) {
    return res.status(400).json({
      message: `Campos obrigatórios não informados: ${missingFields.join(', ')}`
    });
  }

  try {
    const user = await registerUser(req.body);

    return res.status(201).json({
      message: 'Usuário criado com sucesso!',
      user
    });
  } catch (error) {
    const status = error.status || 500;
    const message =
      status === 500 ? 'Erro ao criar usuário.' : error.message || 'Erro.';
    return res.status(status).json({ message });
  }
};

export const handleLogin = async (req, res) => {
  const missingFields = validateRequiredFields(req.body, ['email', 'password']);

  if (missingFields.length > 0) {
    return res.status(400).json({
      message: 'Email e senha são obrigatórios.'
    });
  }

  try {
    const { token, user } = await loginUser(req.body);
    return res.json({
      message: 'Login realizado com sucesso!',
      token,
      user
    });
  } catch (error) {
    const status = error.status || 500;
    const message =
      status === 500 ? 'Erro ao realizar login.' : error.message || 'Erro.';
    return res.status(status).json({ message });
  }
};

export const handleCurrentUser = async (req, res) => {
  const userId = req.user?.id;

  if (!userId) {
    return res.status(400).json({ message: 'Usuário não identificado.' });
  }

  try {
    const user = await getUserById(userId);
    return res.json({ user });
  } catch (error) {
    const status = error.status || 500;
    const message =
      status === 500 ? 'Erro ao carregar usuário.' : error.message || 'Erro.';
    return res.status(status).json({ message });
  }
};

import { listMembers, updateMemberRole } from '../services/user.service.js';

const validRoles = ['Membro', 'Administrador'];

export const handleListMembers = async (_req, res) => {
  try {
    const members = await listMembers();
    return res.json(members);
  } catch (error) {
    console.error('Failed to list members', error);
    return res
      .status(500)
      .json({ message: 'Erro ao listar membros da igreja.' });
  }
};

export const handleUpdateMemberRole = async (req, res) => {
  const memberId = Number(req.params.id);
  const { role } = req.body || {};

  if (!Number.isInteger(memberId) || memberId <= 0) {
    return res.status(400).json({ message: 'ID inválido.' });
  }

  if (typeof role !== 'string' || !validRoles.includes(role)) {
    return res
      .status(400)
      .json({ message: 'Papel inválido. Use "Membro" ou "Administrador".' });
  }

  try {
    const user = await updateMemberRole({ userId: memberId, role });
    return res.json({
      message: 'Papel atualizado com sucesso.',
      user
    });
  } catch (error) {
    const status = error.status || 500;
    const message =
      status === 500 ? 'Erro ao atualizar papel.' : error.message || 'Erro.';
    return res.status(status).json({ message });
  }
};

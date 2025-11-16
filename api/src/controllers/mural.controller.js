import {
  getMuralItems,
  createMuralItem,
  deleteMuralItem
} from '../services/mural.service.js';

const requiredFields = ['title', 'subtitle', 'publish_date'];

const findMissingFields = (body) =>
  requiredFields.filter((field) => {
    const value = body[field];
    return value === undefined || value === null || String(value).trim() === '';
  });

export const listMural = async (_req, res) => {
  try {
    const items = await getMuralItems();
    return res.json(items);
  } catch (error) {
    console.error('Failed to list mural items', error);
    return res.status(500).json({ message: 'Erro ao listar mural.' });
  }
};

export const createMural = async (req, res) => {
  const missingFields = findMissingFields(req.body || {});

  if (missingFields.length > 0) {
    return res.status(400).json({
      message: `Campos obrigatórios ausentes: ${missingFields.join(', ')}`
    });
  }

  try {
    const item = await createMuralItem({
      title: req.body.title,
      subtitle: req.body.subtitle,
      publish_date: req.body.publish_date,
      link: req.body.link
    });

    return res.status(201).json({
      message: 'Aviso criado com sucesso!',
      item
    });
  } catch (error) {
    console.error('Failed to create mural item', error);
    return res.status(500).json({ message: 'Erro ao criar aviso.' });
  }
};

export const removeMural = async (req, res) => {
  const id = Number(req.params.id);

  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ message: 'ID inválido.' });
  }

  try {
    const deleted = await deleteMuralItem(id);

    if (!deleted) {
      return res.status(404).json({ message: 'Aviso não encontrado.' });
    }

    return res.json({ message: 'Aviso removido com sucesso.' });
  } catch (error) {
    console.error('Failed to delete mural item', error);
    return res.status(500).json({ message: 'Erro ao remover aviso.' });
  }
};

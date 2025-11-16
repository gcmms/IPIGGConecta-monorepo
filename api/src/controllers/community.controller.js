import {
  getCommunityPosts,
  createCommunityPost,
  toggleCommunityLike,
  createCommunityComment,
  listCommunityComments
} from '../services/community.service.js';

const ensureFields = (body, fields) => {
  return fields.filter((field) => {
    const value = body[field];
    return value === undefined || value === null || String(value).trim() === '';
  });
};

export const listCommunityFeed = async (req, res) => {
  try {
    const userId = req.query.userId ? Number(req.query.userId) : undefined;
    const items = await getCommunityPosts(userId);
    return res.json(items);
  } catch (error) {
    console.error('Failed to list community posts', error);
    return res.status(500).json({ message: 'Erro ao carregar o feed.' });
  }
};

export const createCommunityEntry = async (req, res) => {
  const missingFields = ensureFields(req.body || {}, ['user_id', 'content']);

  if (missingFields.length > 0) {
    return res.status(400).json({
      message: `Campos obrigatórios ausentes: ${missingFields.join(', ')}`
    });
  }

  try {
    const post = await createCommunityPost({
      user_id: Number(req.body.user_id),
      content: req.body.content
    });

    return res.status(201).json({
      message: 'Publicação criada com sucesso!',
      post
    });
  } catch (error) {
    console.error('Failed to create community post', error);
    return res.status(500).json({ message: 'Erro ao criar publicação.' });
  }
};

export const likeCommunityPost = async (req, res) => {
  const missingFields = ensureFields(req.body || {}, ['user_id']);

  if (missingFields.length > 0) {
    return res.status(400).json({
      message: 'user_id é obrigatório.'
    });
  }

  const postId = Number(req.params.id);

  if (!Number.isInteger(postId) || postId <= 0) {
    return res.status(400).json({ message: 'ID inválido.' });
  }

  try {
    const result = await toggleCommunityLike({
      postId,
      userId: Number(req.body.user_id)
    });

    return res.json({
      message: result.liked
        ? 'Publicação curtida com sucesso.'
        : 'Curtida removida.',
      liked: result.liked,
      likes_count: result.likesCount
    });
  } catch (error) {
    console.error('Failed to toggle like', error);
    return res.status(500).json({ message: 'Erro ao curtir publicação.' });
  }
};

export const commentCommunityPost = async (req, res) => {
  const missingFields = ensureFields(req.body || {}, ['user_id', 'comment']);

  if (missingFields.length > 0) {
    return res.status(400).json({
      message: `Campos obrigatórios ausentes: ${missingFields.join(', ')}`
    });
  }

  const postId = Number(req.params.id);

  if (!Number.isInteger(postId) || postId <= 0) {
    return res.status(400).json({ message: 'ID inválido.' });
  }

  try {
    const result = await createCommunityComment({
      postId,
      userId: Number(req.body.user_id),
      comment: req.body.comment
    });

    return res.status(201).json({
      message: 'Comentário enviado!',
      comments: result.comments,
      comments_count: result.commentsCount
    });
  } catch (error) {
    console.error('Failed to create comment', error);
    return res.status(500).json({ message: 'Erro ao comentar.' });
  }
};

export const listCommunityCommentsController = async (req, res) => {
  const postId = Number(req.params.id);

  if (!Number.isInteger(postId) || postId <= 0) {
    return res.status(400).json({ message: 'ID inválido.' });
  }

  try {
    const comments = await listCommunityComments(postId);
    return res.json(comments);
  } catch (error) {
    console.error('Failed to list comments', error);
    return res.status(500).json({ message: 'Erro ao listar comentários.' });
  }
};

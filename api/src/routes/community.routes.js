import { Router } from 'express';
import {
  listCommunityFeed,
  createCommunityEntry,
  likeCommunityPost,
  commentCommunityPost,
  listCommunityCommentsController
} from '../controllers/community.controller.js';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Community
 *   description: Feed social, curtidas e comentários.
 */

/**
 * @swagger
 * /community:
 *   get:
 *     tags: [Community]
 *     summary: Lista as publicações mais recentes.
 *     parameters:
 *       - in: query
 *         name: userId
 *         schema:
 *           type: integer
 *         description: ID do usuário autenticado para indicar se o post foi curtido por ele.
 *     responses:
 *       200:
 *         description: Lista de publicações.
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/CommunityPost'
 *       500:
 *         description: Erro ao carregar o feed.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.get('/', listCommunityFeed);

/**
 * @swagger
 * /community:
 *   post:
 *     tags: [Community]
 *     summary: Cria uma nova publicação no feed.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateCommunityPostInput'
 *     responses:
 *       201:
 *         description: Publicação criada.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/CommunityPostResponse'
 *       400:
 *         description: Campos obrigatórios ausentes.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       500:
 *         description: Erro ao criar a publicação.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.post('/', createCommunityEntry);

/**
 * @swagger
 * /community/{id}/like:
 *   post:
 *     tags: [Community]
 *     summary: Alterna a curtida de um post.
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID da publicação.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/LikeCommunityPostInput'
 *     responses:
 *       200:
 *         description: Estado atualizado da curtida.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/CommunityLikeResponse'
 *       400:
 *         description: Parâmetros inválidos.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       500:
 *         description: Erro ao processar a curtida.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.post('/:id/like', likeCommunityPost);

/**
 * @swagger
 * /community/{id}/comments:
 *   post:
 *     tags: [Community]
 *     summary: Adiciona um comentário ao post.
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID da publicação.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CommentCommunityPostInput'
 *     responses:
 *       201:
 *         description: Comentário criado e lista atualizada.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/CommunityCommentsResponse'
 *       400:
 *         description: Dados inválidos.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       500:
 *         description: Erro ao enviar o comentário.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *   get:
 *     tags: [Community]
 *     summary: Lista os comentários de um post.
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID da publicação.
 *     responses:
 *       200:
 *         description: Comentários da publicação.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/CommunityCommentListResponse'
 *       400:
 *         description: ID inválido.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       500:
 *         description: Erro ao listar comentários.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.post('/:id/comments', commentCommunityPost);
router.get('/:id/comments', listCommunityCommentsController);

export default router;

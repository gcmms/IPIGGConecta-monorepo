import { Router } from 'express';
import {
  listMural,
  createMural,
  removeMural
} from '../controllers/mural.controller.js';
import { authenticate, requireAdmin } from '../middleware/auth.middleware.js';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Mural
 *   description: Endpoints responsáveis pelo mural de avisos.
 */

/**
 * @swagger
 * /mural:
 *   get:
 *     tags: [Mural]
 *     summary: Lista todos os avisos do mural.
 *     responses:
 *       200:
 *         description: Lista de avisos ordenada pela data de publicação.
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/MuralItem'
 *       500:
 *         description: Erro ao buscar os avisos.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.get('/', listMural);

/**
 * @swagger
 * /mural:
 *   post:
 *     tags: [Mural]
 *     summary: Cria um novo aviso no mural.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateMuralInput'
 *     responses:
 *       201:
 *         description: Aviso criado com sucesso.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/MuralCreateResponse'
 *       400:
 *         description: Campos obrigatórios ausentes.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       500:
 *         description: Erro interno ao criar o aviso.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.post('/', authenticate, requireAdmin, createMural);

/**
 * @swagger
 * /mural/{id}:
 *   delete:
 *     tags: [Mural]
 *     summary: Remove um aviso existente.
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Identificador do aviso.
 *     responses:
 *       200:
 *         description: Aviso removido.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/DeleteMessageResponse'
 *       400:
 *         description: ID inválido.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       404:
 *         description: Aviso não encontrado.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       500:
 *         description: Erro ao remover o aviso.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 */
router.delete('/:id', authenticate, requireAdmin, removeMural);

export default router;

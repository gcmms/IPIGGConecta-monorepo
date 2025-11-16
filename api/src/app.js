import express from 'express';
import cors from 'cors';
import swaggerUi from 'swagger-ui-express';
import authRoutes from './routes/auth.routes.js';
import muralRoutes from './routes/mural.routes.js';
import communityRoutes from './routes/community.routes.js';
import userRoutes from './routes/users.routes.js';
import swaggerSpec from './config/swagger.js';

const app = express();

app.use(cors());
app.use(express.json());

app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, { explorer: true }));
app.get('/docs.json', (_req, res) => {
  res.json(swaggerSpec);
});

/**
 * @swagger
 * /:
 *   get:
 *     tags: [Health]
 *     summary: Verifica se a API está acessível.
 *     responses:
 *       200:
 *         description: API disponível.
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: IPIGGConecta API is running
 */
app.get('/', (_req, res) => {
  res.json({ message: 'IPIGGConecta API is running' });
});

app.use('/auth', authRoutes);
app.use('/mural', muralRoutes);
app.use('/community', communityRoutes);
app.use('/users', userRoutes);

export default app;

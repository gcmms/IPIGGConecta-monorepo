import { Router } from 'express';
import {
  handleListMembers,
  handleUpdateMemberRole
} from '../controllers/users.controller.js';
import { authenticate, requireAdmin } from '../middleware/auth.middleware.js';

const router = Router();

router.get('/', authenticate, requireAdmin, handleListMembers);
router.patch('/:id/role', authenticate, requireAdmin, handleUpdateMemberRole);

export default router;

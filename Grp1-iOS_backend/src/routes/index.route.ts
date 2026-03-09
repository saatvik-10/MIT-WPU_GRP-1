import { Hono } from 'hono';
import userRoute from './user.route';
import articleRoute from './article.route';

const router = new Hono();

router.route('/auth', userRoute);
router.route('/', articleRoute);

export default router;

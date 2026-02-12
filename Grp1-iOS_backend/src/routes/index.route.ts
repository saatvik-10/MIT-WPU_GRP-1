import { Hono } from 'hono';
import userRoute from './user.route';
import articleRoute from './article.route';
import threadRoute from './threads.route';

const router = new Hono();

router.route('/auth', userRoute);
router.route('/', articleRoute);
router.route('/', threadRoute)

export default router;

import { Hono } from 'hono';
import userRoute from './user.route';
import articleRoute from './article.route';
import threadRoute from './threads.route';
import profileRoute from './profile.route';

const router = new Hono();

router.route('/auth', userRoute);
router.route('/', articleRoute);
router.route('/', threadRoute)
router.route("/", profileRoute)

export default router;

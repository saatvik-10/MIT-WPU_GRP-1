import { Hono } from 'hono';
import userRoute from './user.route';
import articleRoute from './article.route';
import threadRoute from './threads.route';
import profileRoute from './profile.route';
import progressRoute from './progress.route';
import bookmarkRoute from './bookmark.route';

const router = new Hono();

router.route('/auth', userRoute);
router.route('/', articleRoute);
router.route('/', threadRoute)
router.route("/profile", profileRoute)
router.route("/progress", progressRoute)
router.route("/bookmarks", bookmarkRoute)

export default router;

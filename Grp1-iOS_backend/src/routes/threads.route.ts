import { Hono } from 'hono';
import { Threads } from '../controllers/threads.controller';

const threadRoute = new Hono();
const controller = new Threads();

threadRoute.get('for-you-threads', controller.getForYouThreads);
threadRoute.post('following-threads', controller.getFollowingThreads);

export default threadRoute;

import { Hono } from 'hono';
import { Threads } from '../controllers/threads.controller';
import { proxyAuth } from '../proxy';

const threadRoute = new Hono();
const controller = new Threads();

threadRoute.get('for-you-threads', controller.getForYouThreads);
threadRoute.post('following-threads', proxyAuth, controller.getFollowingThreads);
threadRoute.post('follow', proxyAuth, controller.updateFollow);

export default threadRoute;

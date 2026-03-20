import { Hono } from 'hono';
import { Threads } from '../controllers/threads.controller';
import { proxyAuth } from '../proxy';

const threadRoute = new Hono();
const controller = new Threads();

threadRoute.get('/for-you-threads', controller.getForYouThreads);

threadRoute.get('/following-threads', proxyAuth, controller.getFollowingThreads);

threadRoute.post('/follow', proxyAuth, controller.updateFollow);

threadRoute.get('/all-followers', proxyAuth, controller.getAllFollowers);
threadRoute.get('/all-following', proxyAuth, controller.getAllFollowing);

threadRoute.post('/create-thread', proxyAuth, controller.createThread);

threadRoute.post('/draft', proxyAuth, controller.saveDraft);
threadRoute.get('/drafts', proxyAuth, controller.getDrafts);
threadRoute.put('/draft/:draftId', proxyAuth, controller.updateDraft);
threadRoute.delete('/draft', proxyAuth, controller.deleteDraft)

threadRoute.delete('/thread', proxyAuth, controller.deleteThread)

export default threadRoute;

import { Hono } from 'hono';
import { UserProgress } from '../controllers/progress.controller';
import { proxyAuth } from '../proxy';

const progressRoute = new Hono();
const controller = new UserProgress();

progressRoute.post('/', proxyAuth, controller.updateProgress);
progressRoute.get('/', proxyAuth, controller.getUserProgress);

export default progressRoute;

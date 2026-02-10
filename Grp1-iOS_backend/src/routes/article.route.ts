import { Hono } from 'hono';
import { proxyAuth } from '../proxy';

const articleRoute = new Hono();

articleRoute.post('chat/question');
articleRoute.post('quiz/summary');
articleRoute.get('chat/questions/:articleUrl');

export default articleRoute;

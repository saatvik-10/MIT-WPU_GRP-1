import { Hono } from 'hono';
import { proxyAuth } from '../proxy';

const articleRoute = new Hono();

articleRoute.get('articles', proxyAuth);
articleRoute.get('article:id');
articleRoute.get('explore');
articleRoute.post('chat-question');
articleRoute.post('jargon-quiz');
articleRoute.post('summary-quiz');

export default articleRoute
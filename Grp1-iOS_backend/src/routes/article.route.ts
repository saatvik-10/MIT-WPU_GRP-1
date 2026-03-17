import { Hono } from 'hono';
import { Articles } from '../controllers/article.controller';

const articleRoute = new Hono();
const controller = new Articles()

articleRoute.post('chat/question', controller.postChatQuestion);
articleRoute.post('article', controller.summaryQuiz);
articleRoute.get('chat/questions', controller.allChatQuestions);

export default articleRoute;

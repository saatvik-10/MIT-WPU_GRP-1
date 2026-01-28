import { Hono } from 'hono';
import { proxyAuth } from '../proxy';
import { UserAuth } from '../controllers/user.controller';

const userRoute = new Hono();
const controller = new UserAuth();

userRoute.post('/signup', controller.signUp);
userRoute.post('/signin', controller.signIn);
userRoute.post('/signout');
userRoute.get('/me', proxyAuth);

export default userRoute;

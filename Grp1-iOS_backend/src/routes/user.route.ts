import { Hono } from 'hono';
import { proxyAuth } from '../proxy';
import { UserAuth } from '../controllers/user.controller';

const userRoute = new Hono();
const controller = new UserAuth();

userRoute.post('/signup', controller.signup);
userRoute.post('/signin');
userRoute.post('/signout');
userRoute.get('/me', proxyAuth);

export default userRoute;

import { Hono } from 'hono';
import { proxyAuth } from '../proxy';

const userRoute = new Hono();

userRoute.post('/signup');
userRoute.post('/signin');
userRoute.post('/signout');
userRoute.get('/me', proxyAuth);

export default userRoute;

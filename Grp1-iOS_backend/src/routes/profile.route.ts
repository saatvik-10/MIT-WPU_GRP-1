import { Hono } from 'hono';
import { Profile } from '../controllers/profile.controller';
import { proxyAuth } from '../proxy';

const profileRoute = new Hono();
const controller = new Profile();

profileRoute.get('profile', proxyAuth, controller.getProfile);

export default profileRoute;

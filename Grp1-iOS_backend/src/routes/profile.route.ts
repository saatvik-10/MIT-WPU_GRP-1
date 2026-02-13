import { Hono } from 'hono';
import { Profile } from '../controllers/profile.controller';
import { proxyAuth } from '../proxy';

const profileRoute = new Hono();
const controller = new Profile();

profileRoute.get('/profile', proxyAuth, controller.getProfile);
profileRoute.get('/interests', proxyAuth, controller.getUserInterests);
profileRoute.delete('/interests/:interestId', proxyAuth, controller.deleteUserInterest);

export default profileRoute;

import { Hono } from 'hono';
import { Profile } from '../controllers/profile.controller';
import { proxyAuth } from '../proxy';

const profileRoute = new Hono();
const controller = new Profile();

profileRoute.get('/profile', proxyAuth, controller.getProfile);
profileRoute.patch('/profile', proxyAuth, controller.editProfile);
profileRoute.get(
  '/users/:userId/profile',
  proxyAuth,
  controller.getUserProfile,
);
profileRoute.get(
  '/users/:userId/followers',
  proxyAuth,
  controller.getFollowers,
);
profileRoute.get(
  '/users/:userId/following',
  proxyAuth,
  controller.getFollowing,
);
profileRoute.get('/interests', proxyAuth, controller.getUserInterests);
profileRoute.get('/interests/available', controller.getAvailableInterests);
profileRoute.post('/interests', proxyAuth, controller.addUserInterest);
profileRoute.delete(
  '/interests/:interestId',
  proxyAuth,
  controller.deleteUserInterest,
);
profileRoute.get(
  '/bookmarks/folders',
  proxyAuth,
  controller.getBookmarkFolders,
);
profileRoute.post(
  '/bookmarks/folders',
  proxyAuth,
  controller.createBookmarkFolder,
);
profileRoute.get('/bookmarks', proxyAuth, controller.getBookmarks);
profileRoute.post('/bookmarks', proxyAuth, controller.createBookmark);

export default profileRoute;

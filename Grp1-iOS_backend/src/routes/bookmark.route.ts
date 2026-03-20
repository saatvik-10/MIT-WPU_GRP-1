import { Hono } from 'hono';
import { Bookmarks } from '../controllers/bookmark.controller';
import { proxyAuth } from '../proxy';

const bookmarkRoute = new Hono();
const controller = new Bookmarks();

bookmarkRoute.post('/folders', proxyAuth, controller.createBookmarkFolder);
bookmarkRoute.get('/folders', proxyAuth, controller.getBookmarkFolders);
bookmarkRoute.delete('/folders/:folderId', proxyAuth, controller.deleteBookmarkFolder);

bookmarkRoute.post('/articles', proxyAuth, controller.createBookmarkedArticle);
bookmarkRoute.get('/articles', proxyAuth, controller.getBookmarkedArticles);
bookmarkRoute.delete('/articles/:articleId', proxyAuth, controller.deleteBookmarkedArticle);

bookmarkRoute.post('/threads', proxyAuth, controller.createBookmarkedThread);
bookmarkRoute.get('/threads', proxyAuth, controller.getBookmarkedThreads);
bookmarkRoute.delete('/threads/:threadId', proxyAuth, controller.deleteBookmarkedThread);

export default bookmarkRoute;

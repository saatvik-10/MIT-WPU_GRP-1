import { Hono } from 'hono';
import { logger } from 'hono/logger';
import { cors } from 'hono/cors';

const PORT = process.env.PORT || 8000;

const app = new Hono();

app.use(logger());

app.use(cors());

app.notFound((c) => {
  return c.json({ err: 'Page Not Found' }, 404);
});

export default {
  PORT,
  fetch: app.fetch,
};

import { Hono } from 'hono';
import { logger } from 'hono/logger';
import { cors } from 'hono/cors';
import router from './routes/index.route';
import { serve } from '@hono/node-server';

const PORT = process.env.PORT;

const app = new Hono();

app.use(logger());
app.use(cors());

app.route('/api', router);

app.get('health', (c) => {
  return c.json({ status: 'ok' });
});

app.notFound((c) => {
  return c.json({ err: 'Page Not Found' }, 404);
});

serve({
  fetch: app.fetch,
  port: Number(PORT),
});

console.log(`Server running on port ${PORT}`);

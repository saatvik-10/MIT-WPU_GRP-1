import { Hono } from 'hono';
import userRoute from './user.route'

const router = new Hono()

router.route("/auth", userRoute)

export default router
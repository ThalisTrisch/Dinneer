import { Router } from 'express';
import { NotificationController } from './notification.controller';

const router = Router();
const notificationController = new NotificationController();

router.post('/send-chat', (req, res, next) => {
  notificationController.handle(req, res, next);
});

export default router;

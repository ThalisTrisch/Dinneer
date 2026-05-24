import { Request, Response, NextFunction } from 'express';
import { Database } from '../../database/Database';
import { NotificationService } from './notification.service';

export class NotificationController {
  async handle(req: Request, res: Response, _next: NextFunction): Promise<void> {
    const banco = new Database();
    const notificationService = new NotificationService(banco);

    try {
      const encontroId = parseInt(req.body.id_encontro);
      const senderId = parseInt(req.body.id_usuario);
      const senderName = req.body.nm_usuario as string;
      const messageText = req.body.tx_mensagem as string;

      if (!encontroId) throw new Error('id_encontro faltando');
      if (!senderId) throw new Error('id_usuario faltando');
      if (!senderName) throw new Error('nm_usuario faltando');
      if (!messageText) throw new Error('tx_mensagem faltando');

      await notificationService.sendChatNotification(
        encontroId,
        senderId,
        senderName,
        messageText
      );

      res.json(banco.getRetorno('sendChatNotification'));
    } catch (error: any) {
      banco.setMensagem(1, error.message || 'Erro desconhecido');
      res.json(banco.getRetorno('sendChatNotification'));
    }
  }
}

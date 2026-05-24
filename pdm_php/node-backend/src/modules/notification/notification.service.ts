import { BaseService } from '../../database/BaseService';
import { Database } from '../../database/Database';
import { getFirebaseAdmin } from '../../config/firebase';

export class NotificationService extends BaseService {
  constructor(banco: Database) {
    super(banco);
  }

  async sendChatNotification(
    encontroId: number,
    senderId: number,
    senderName: string,
    messageText: string
  ): Promise<void> {
    const result = await this.conexao.query(
      'SELECT id_usuario FROM tb_encontro_usuario_dn WHERE id_encontro = $1',
      [encontroId]
    );

    const recipientIds: number[] = result.rows
      .map((r: { id_usuario: number }) => r.id_usuario)
      .filter((id: number) => id !== senderId);

    if (recipientIds.length === 0) {
      this.banco.setMensagem(0, 'Nenhum destinatário encontrado');
      return;
    }

    const db = getFirebaseAdmin().database();
    const messaging = getFirebaseAdmin().messaging();
    let sent = 0;

    for (const userId of recipientIds) {
      const userIdStr = userId.toString();

      const tokenSnap = await db.ref(`users/${userIdStr}/fcmToken`).get();
      const token: string | null = tokenSnap.val();
      if (!token) continue;

      const countRef = db.ref(`unread_counts/${encontroId}/${userIdStr}`);
      const countSnap = await countRef.get();
      const unreadCount: number = countSnap.val() ?? 0;

      if (unreadCount >= 2) continue;

      const body =
        messageText.length > 100
          ? `${messageText.substring(0, 97)}...`
          : messageText;

      await messaging.send({
        token,
        notification: { title: senderName, body },
        data: { encontroId: encontroId.toString(), type: 'chat_message' },
        android: { priority: 'high' },
        apns: { payload: { aps: { sound: 'default' } } },
      });

      await countRef.set(unreadCount + 1);
      sent++;
    }

    this.banco.setMensagem(0, `${sent} notificação(ões) enviada(s)`);
  }
}

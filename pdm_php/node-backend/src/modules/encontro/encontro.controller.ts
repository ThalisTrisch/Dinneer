import { Request, Response, NextFunction } from 'express';
import { Database } from '../../database/Database';
import { EncontroService } from './encontro.service';

/**
 * EncontroController - Equivalente ao EncontroController.php
 * Gerencia as requisições HTTP e delega para o Service
 */
export class EncontroController {
  /**
   * Método principal que roteia as operações baseado no query param ?operacao=
   */
  async handle(req: Request, res: Response, next: NextFunction): Promise<void> {
    const banco = new Database();
    const encontroService = new EncontroService(banco);

    try {
      const operacao = req.query.operacao as string || 'Não informado';

      switch (operacao) {
        case 'reservar':
        case 'addUsuarioEncontro':
          const id_encontro_add = parseInt(req.body.id_encontro);
          const id_usuario_add = parseInt(req.body.id_usuario);
          const deps = parseInt(req.body.nu_dependentes) || 0;

          if (!id_encontro_add) throw new Error('id_encontro faltando');
          if (!id_usuario_add) throw new Error('id_usuario faltando');

          await encontroService.addUsuarioEncontro(id_usuario_add, id_encontro_add, deps);
          break;

        case 'aprovarReserva':
          const id_encontro_aprovar = parseInt(req.body.id_encontro);
          const id_convidado_aprovar = parseInt(req.body.id_convidado);

          if (!id_encontro_aprovar) throw new Error('id_encontro faltando');
          if (!id_convidado_aprovar) throw new Error('id_convidado faltando');

          await encontroService.aprovarReserva(id_encontro_aprovar, id_convidado_aprovar);
          break;

        case 'rejeitarReserva':
          const id_encontro_rejeitar = parseInt(req.body.id_encontro);
          const id_convidado_rejeitar = parseInt(req.body.id_convidado);

          if (!id_encontro_rejeitar) throw new Error('id_encontro faltando');
          if (!id_convidado_rejeitar) throw new Error('id_convidado faltando');

          await encontroService.rejeitarReserva(id_encontro_rejeitar, id_convidado_rejeitar);
          break;

        case 'getParticipantes':
          const id_encontro_part = parseInt(req.query.id_encontro as string);

          if (!id_encontro_part) throw new Error('id_encontro faltando');

          await encontroService.getParticipantes(id_encontro_part);
          break;

        case 'cancelarReserva':
        case 'deleteUsuarioEncontro':
          const id_encontro_cancel = parseInt(req.body.id_encontro);
          const id_usuario_cancel = parseInt(req.body.id_usuario);

          if (!id_encontro_cancel) throw new Error('id_encontro faltando');
          if (!id_usuario_cancel) throw new Error('id_usuario faltando');

          await encontroService.deleteUsuarioEncontro(id_usuario_cancel, id_encontro_cancel);
          break;

        case 'verificarReserva':
          const id_encontro_verif = parseInt(req.query.id_encontro as string);
          const id_usuario_verif = parseInt(req.query.id_usuario as string);

          if (!id_encontro_verif) throw new Error('id_encontro faltando');
          if (!id_usuario_verif) throw new Error('id_usuario faltando');

          await encontroService.verificarReserva(id_usuario_verif, id_encontro_verif);
          break;

        case 'getMinhasReservas':
          const id_usuario_reservas = parseInt(req.query.id_usuario as string);

          if (!id_usuario_reservas) throw new Error('id_usuario faltando');

          await encontroService.getMinhasReservas(id_usuario_reservas);
          break;

        case 'getMeusJantaresCriados':
          const id_usuario_jantares = parseInt(req.query.id_usuario as string);

          if (!id_usuario_jantares) throw new Error('id_usuario faltando');

          await encontroService.getMeusJantaresCriados(id_usuario_jantares);
          break;

        default:
          banco.setMensagem(1, 'Operação não tratada: ' + operacao);
          break;
      }

      res.json(banco.getRetorno(operacao));
    } catch (error: any) {
      banco.setMensagem(1, error.message || 'Erro desconhecido');
      res.json(banco.getRetorno(req.query.operacao as string || 'erro'));
    }
  }
}

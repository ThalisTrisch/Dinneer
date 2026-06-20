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
  async handle(req: Request, res: Response, _next: NextFunction): Promise<void> {
    const banco = new Database();
    const encontroService = new EncontroService(banco);

    try {
      const operacao = req.query.operacao as string || 'Não informado';

      switch (operacao) {
        case 'reservar':
        case 'addUsuarioEncontro':
          if (!req.usuarioId) throw new Error('Autenticação necessária.');
          const id_encontro_add = parseInt(req.body.id_encontro);
          const deps = parseInt(req.body.nu_dependentes) || 0;

          if (!id_encontro_add) throw new Error('id_encontro faltando');

          await encontroService.addUsuarioEncontro(req.usuarioId, id_encontro_add, deps);
          break;

        case 'aprovarReserva':
          if (!req.usuarioId) throw new Error('Autenticação necessária.');
          const id_encontro_aprovar = parseInt(req.body.id_encontro);
          const id_convidado_aprovar = parseInt(req.body.id_convidado);

          if (!id_encontro_aprovar) throw new Error('id_encontro faltando');
          if (!id_convidado_aprovar) throw new Error('id_convidado faltando');

          const anfitriaoAprovar = await encontroService.getIdAnfitriaoPorEncontro(id_encontro_aprovar);
          if (anfitriaoAprovar !== req.usuarioId) {
            throw new Error('Apenas o anfitrião pode gerenciar este jantar.');
          }

          await encontroService.aprovarReserva(id_encontro_aprovar, id_convidado_aprovar);
          break;

        case 'rejeitarReserva':
          if (!req.usuarioId) throw new Error('Autenticação necessária.');
          const id_encontro_rejeitar = parseInt(req.body.id_encontro);
          const id_convidado_rejeitar = parseInt(req.body.id_convidado);

          if (!id_encontro_rejeitar) throw new Error('id_encontro faltando');
          if (!id_convidado_rejeitar) throw new Error('id_convidado faltando');

          const anfitriaoRejeitar = await encontroService.getIdAnfitriaoPorEncontro(id_encontro_rejeitar);
          if (anfitriaoRejeitar !== req.usuarioId) {
            throw new Error('Apenas o anfitrião pode gerenciar este jantar.');
          }

          await encontroService.rejeitarReserva(id_encontro_rejeitar, id_convidado_rejeitar);
          break;

        case 'getParticipantes':
          if (!req.usuarioId) throw new Error('Autenticação necessária.');
          const id_encontro_part = parseInt(req.query.id_encontro as string);

          if (!id_encontro_part) throw new Error('id_encontro faltando');

          const anfitriaoPart = await encontroService.getIdAnfitriaoPorEncontro(id_encontro_part);
          if (anfitriaoPart !== req.usuarioId) {
            throw new Error('Apenas o anfitrião pode ver os participantes.');
          }

          await encontroService.getParticipantes(id_encontro_part);
          break;

        case 'cancelarReserva':
        case 'deleteUsuarioEncontro':
          if (!req.usuarioId) throw new Error('Autenticação necessária.');
          const id_encontro_cancel = parseInt(req.body.id_encontro);

          if (!id_encontro_cancel) throw new Error('id_encontro faltando');

          await encontroService.deleteUsuarioEncontro(req.usuarioId, id_encontro_cancel);
          break;

        case 'verificarReserva':
          if (!req.usuarioId) throw new Error('Autenticação necessária.');
          const id_encontro_verif = parseInt(req.query.id_encontro as string);

          if (!id_encontro_verif) throw new Error('id_encontro faltando');

          await encontroService.verificarReserva(req.usuarioId, id_encontro_verif);
          break;

        case 'getMinhasReservas':
          if (!req.usuarioId) throw new Error('Autenticação necessária.');
          await encontroService.getMinhasReservas(req.usuarioId);
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

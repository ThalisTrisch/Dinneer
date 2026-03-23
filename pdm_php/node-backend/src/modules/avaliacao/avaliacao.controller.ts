import { Request, Response, NextFunction } from 'express';
import { Database } from '../../database/Database';
import { AvaliacaoService } from './avaliacao.service';

/**
 * AvaliacaoController - Equivalente ao AvaliacaoController.php
 * Gerencia as requisições HTTP e delega para o Service
 */
export class AvaliacaoController {
  /**
   * Método principal que roteia as operações baseado no query param ?operacao=
   */
  async handle(req: Request, res: Response, next: NextFunction): Promise<void> {
    const banco = new Database();
    const avaliacaoService = new AvaliacaoService(banco);

    try {
      const operacao = req.query.operacao as string || 'Não informado';

      switch (operacao) {
        case 'getTiposAvaliacao':
          await avaliacaoService.getTiposAvaliacao();
          break;

        case 'createAvaliacao':
          const id_usuario = parseInt(req.body.id_usuario);
          const id_encontro = parseInt(req.body.id_encontro);
          const id_avaliacao = parseInt(req.body.id_avaliacao);
          const vl_avaliacao = parseInt(req.body.vl_avaliacao);

          if (!id_usuario) throw new Error('Faltou id_usuario');
          if (!id_encontro) throw new Error('Faltou id_encontro');
          if (!id_avaliacao) throw new Error('Faltou id_avaliacao (tipo)');
          if (!vl_avaliacao) throw new Error('Faltou nota');

          await avaliacaoService.createAvaliacao(id_usuario, id_encontro, vl_avaliacao, id_avaliacao);
          break;

        case 'getMediaUsuario':
          const id_usuario_media = parseInt(req.query.id_usuario as string);

          if (!id_usuario_media) throw new Error('Faltou id_usuario');

          await avaliacaoService.getMediaAvaliacaoUsuario(id_usuario_media);
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

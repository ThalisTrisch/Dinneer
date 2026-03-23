import { Request, Response, NextFunction } from 'express';
import { Database } from '../../database/Database';
import { ImagemService } from './imagem.service';

/**
 * ImagemController - Equivalente ao imagemController.php
 * Gerencia as requisições HTTP e delega para o Service
 */
export class ImagemController {
  /**
   * Método principal que roteia as operações baseado no query param ?operacao=
   */
  async handle(req: Request, res: Response, next: NextFunction): Promise<void> {
    const banco = new Database();
    const imagemService = new ImagemService(banco);

    try {
      const operacao = req.query.operacao as string || 'Não informado';

      switch (operacao) {
        case 'getImagem':
          const id_imagem = parseInt(req.query.id_imagem as string);

          if (!id_imagem) throw new Error('campo id_imagem não fornecido');

          await imagemService.getImagem(id_imagem);
          break;

        case 'createImagem':
          const id_sequence = parseInt(req.body.id_sequence);
          const vl_url = req.body.vl_url;

          if (!id_sequence) throw new Error('campo id_sequence não fornecido');
          if (!vl_url) throw new Error('campo vl_url não fornecido');

          await imagemService.createImagem(id_sequence, vl_url);
          break;

        case 'deleteImagem':
          const id_imagem_delete = parseInt(req.body.id_imagem);

          if (!id_imagem_delete) throw new Error('campo id_imagem não fornecido');

          await imagemService.deleteImagem(id_imagem_delete);
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

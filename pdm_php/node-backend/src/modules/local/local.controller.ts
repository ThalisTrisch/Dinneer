import { Request, Response, NextFunction } from 'express';
import { Database } from '../../database/Database';
import { LocalService } from './local.service';

/**
 * LocalController - Equivalente ao LocalController.php
 * Gerencia as requisições HTTP e delega para o Service
 */
export class LocalController {
  /**
   * Método principal que roteia as operações baseado no query param ?operacao=
   */
  async handle(req: Request, res: Response, _next: NextFunction): Promise<void> {
    const banco = new Database();
    const localService = new LocalService(banco);

    try {
      // Pega a operação do query string
      const operacao = req.query.operacao as string || 'Não informado [Erro]';

      switch (operacao) {
        case 'getLocal':
          if (!req.usuarioId) throw new Error('Autenticação necessária.');
          const id_local = parseInt(req.query.id_local as string);
          if (!id_local) {
            throw new Error('id_local não definido');
          }
          await localService.getLocal(id_local);
          break;

        case 'getLocais':
          if (!req.usuarioId) throw new Error('Autenticação necessária.');
          await localService.getLocais();
          break;

        case 'getMeusLocais':
          // Só lista os locais do próprio usuário (identidade vem do token)
          if (!req.usuarioId) throw new Error('Autenticação necessária.');
          await localService.getMeusLocais(req.usuarioId);
          break;

        case 'createLocal':
          if (!req.usuarioId) throw new Error('Autenticação necessária.');
          const createData = {
            nu_cep: req.body.nu_cep,
            nu_casa: req.body.nu_casa,
            id_usuario: req.usuarioId,
            nu_cnpj: req.body.nu_cnpj || null,
            dc_complemento: req.body.dc_complemento || null,
          };

          // Validações
          if (!createData.nu_cep) throw new Error('campo nu_cep não fornecido');
          if (!createData.nu_casa) throw new Error('campo nu_casa não fornecido');

          await localService.createLocal(createData);
          break;

        case 'deleteLocal':
          if (!req.usuarioId) throw new Error('Autenticação necessária.');
          const id_delete = parseInt(req.body.id_local);
          if (!id_delete) throw new Error('campo id_local não fornecido');

          const donoLocal = await localService.getIdDonoPorLocal(id_delete);
          if (donoLocal !== req.usuarioId) {
            throw new Error('Apenas o dono pode excluir este local.');
          }

          await localService.deleteLocal(id_delete);
          break;

        default:
          banco.setMensagem(1, 'Operação informada não tratada. Operação=' + operacao);
          break;
      }

      // Retorna a resposta formatada
      res.json(banco.getRetorno(operacao));
    } catch (error: any) {
      banco.setMensagem(1, error.message || 'Erro desconhecido');
      res.json(banco.getRetorno(req.query.operacao as string || 'erro'));
    }
  }
}

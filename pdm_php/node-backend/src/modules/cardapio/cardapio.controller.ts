import { Request, Response, NextFunction } from 'express';
import { Database } from '../../database/Database';
import { CardapioService } from './cardapio.service';

/**
 * CardapioController - Equivalente ao CardapioController.php
 * Gerencia as requisições HTTP e delega para o Service
 */
export class CardapioController {
  /**
   * Método principal que roteia as operações baseado no query param ?operacao=
   */
  async handle(req: Request, res: Response, _next: NextFunction): Promise<void> {
    const banco = new Database();
    const cardapioService = new CardapioService(banco);

    try {
      // Pega a operação do query string
      const operacao = req.query.operacao as string || 'Não informado [Erro]';

      switch (operacao) {
        case 'getCardapiosDisponiveis':
          await cardapioService.getCardapiosDisponiveis();
          break;

        case 'getCardapiosPorCategoria':
          const categoria = req.query.categoria as string || req.body.categoria;
          if (!categoria) throw new Error('categoria não informada');
          await cardapioService.getCardapiosPorCategoria(categoria);
          break;

        case 'getCategorias':
          await cardapioService.getCategorias();
          break;

        case 'createJantar':
        case 'createJantarCompleto':
          if (!req.usuarioId) throw new Error('Autenticação necessária.');
          const createData = {
            id_usuario: req.usuarioId,
            nm_cardapio: req.body.nm_cardapio,
            ds_cardapio: req.body.ds_cardapio,
            preco_refeicao: parseFloat(req.body.preco_refeicao),
            hr_encontro: req.body.hr_encontro,
            nu_max_convidados: parseInt(req.body.nu_max_convidados),
            nu_cep: req.body.nu_cep || null,
            nu_casa: req.body.nu_casa || null,
            vl_foto: req.body.vl_foto || null,
            id_local: req.body.id_local || null,
            categoria: req.body.categoria || null,
          };

          // Validações
          if (!createData.nm_cardapio) throw new Error('Faltou titulo');
          if (!createData.ds_cardapio) throw new Error('Faltou descricao');
          if (!createData.preco_refeicao) throw new Error('Faltou preco');
          if (!createData.hr_encontro) throw new Error('Faltou data');
          if (!createData.nu_max_convidados) throw new Error('Faltou vagas');

          await cardapioService.createJantarCompleto(createData);
          break;

        case 'getMeuCardapio':
          const id_local = parseInt(req.query.id_local as string);
          if (!id_local) throw new Error('id_local não informado');
          // Implementar se necessário
          throw new Error('Operação getMeuCardapio não implementada ainda');

        case 'deleteCardapio':
        case 'deleteJantar':
          if (!req.usuarioId) throw new Error('Autenticação necessária.');
          const id_cardapio_delete = parseInt(req.body.id_cardapio);
          if (!id_cardapio_delete) throw new Error('id_cardapio faltando');

          const donoDelete = await cardapioService.getIdDonoPorCardapio(id_cardapio_delete);
          if (donoDelete !== req.usuarioId) {
            throw new Error('Apenas o anfitrião pode excluir este jantar.');
          }

          await cardapioService.deleteJantar(id_cardapio_delete);
          break;

        case 'updateJantar':
          if (!req.usuarioId) throw new Error('Autenticação necessária.');
          const updateData = {
            id_cardapio: parseInt(req.body.id_cardapio),
            nm_cardapio: req.body.nm_cardapio,
            ds_cardapio: req.body.ds_cardapio,
            preco_refeicao: parseFloat(req.body.preco_refeicao),
            hr_encontro: req.body.hr_encontro,
            nu_max_convidados: parseInt(req.body.nu_max_convidados),
            nu_cep: req.body.nu_cep,
            nu_casa: req.body.nu_casa,
            vl_foto: req.body.vl_foto,
          };

          if (!updateData.id_cardapio) throw new Error('Faltou ID');

          const donoUpdate = await cardapioService.getIdDonoPorCardapio(updateData.id_cardapio);
          if (donoUpdate !== req.usuarioId) {
            throw new Error('Apenas o anfitrião pode editar este jantar.');
          }

          await cardapioService.updateJantar(updateData);
          break;

        default:
          banco.setMensagem(1, 'Operação informada não tratada: ' + operacao);
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

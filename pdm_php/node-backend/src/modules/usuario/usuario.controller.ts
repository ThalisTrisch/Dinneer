import { Request, Response, NextFunction } from 'express';
import { Database } from '../../database/Database';
import { UsuarioService } from './usuario.service';

/**
 * UsuarioController - Equivalente ao UsuarioController.php
 * Gerencia as requisições HTTP e delega para o Service
 */
export class UsuarioController {
  /**
   * Método principal que roteia as operações baseado no query param ?operacao=
   */
  async handle(req: Request, res: Response, next: NextFunction): Promise<void> {
    const banco = new Database();
    const usuarioService = new UsuarioService(banco);

    try {
      // Pega a operação do query string
      const operacao = req.query.operacao as string || 'Não informado [Erro]';

      switch (operacao) {
        case 'getUsuarios':
          await usuarioService.getUsuarios();
          break;

        case 'getUsuario':
          const id_usuario = parseInt(req.query.id_usuario as string);
          if (!id_usuario) {
            throw new Error('id_usuario não definido');
          }
          await usuarioService.getUsuario(id_usuario);
          break;

        case 'createUsuario':
          const createData = {
            nu_cpf: req.body.nu_cpf,
            nm_usuario: req.body.nm_usuario,
            vl_email: req.body.vl_email,
            nm_sobrenome: req.body.nm_sobrenome,
            vl_senha: req.body.vl_senha,
            vl_foto: req.body.vl_foto || null,
          };

          // Validações
          if (!createData.nu_cpf) throw new Error('nu_cpf não definido');
          if (!createData.nm_usuario) throw new Error('nm_usuario não definido');
          if (!createData.vl_email) throw new Error('vl_email não definido');
          if (!createData.nm_sobrenome) throw new Error('nm_sobrenome não definido');
          if (!createData.vl_senha) throw new Error('vl_senha não definido');

          await usuarioService.createUsuario(createData);
          break;

        case 'deleteUsuario':
          const id_delete = parseInt(req.body.id_usuario);
          if (!id_delete) throw new Error('id_usuario não definido');
          await usuarioService.deleteUsuario(id_delete);
          break;

        case 'updateUsuario':
          // TODO: Implementar updateUsuario
          banco.setMensagem(1, 'updateUsuario ainda não implementado');
          break;

        case 'loginUsuario':
          const loginData = {
            vl_email: req.body.vl_email,
            vl_senha: req.body.vl_senha,
          };

          if (!loginData.vl_email || !loginData.vl_senha) {
            throw new Error('Email ou senha não fornecidos');
          }

          await usuarioService.loginUsuario(loginData);
          break;

        case 'atualizarFotoPerfil':
          const id_foto = parseInt(req.body.id_usuario);
          const vl_foto = req.body.vl_foto;

          if (!id_foto) throw new Error('id_usuario nao fornecido');
          if (!vl_foto) throw new Error('vl_foto nao fornecido');

          await usuarioService.atualizarFotoPerfil(id_foto, vl_foto);
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

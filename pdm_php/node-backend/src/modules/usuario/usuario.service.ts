import crypto from 'crypto';
import { BaseService } from '../../database/BaseService';
import { Database } from '../../database/Database';
import { LoginData } from '../../types';
import { encrypt } from '../../utils/encryption';
import { hashPassword, isHashed, verifyPassword } from '../../utils/password';
import { gerarToken } from '../../utils/token';

/**
 * UsuarioService - Equivalente ao UsuarioService.php
 */
export class UsuarioService extends BaseService {
  constructor(banco: Database) {
    super(banco);
  }

  private emailPermitido(email: string): boolean {
    return /^[^\s@]+@[^\s@]+$/.test(email.trim());
  }

  /**
   * Login do usuário
   */
  async loginUsuario(loginData: LoginData): Promise<void> {
    if (!loginData.vl_email || !loginData.vl_senha) {
      throw new Error('Email ou senha não fornecidos.');
    }

    // Busca usuário no banco
    const sql = `
      SELECT id_usuario, nm_usuario, nm_sobrenome, vl_email, vl_senha, vl_foto, vl_foto_capa
      FROM tb_usuario_dn
      WHERE vl_email = $1
    `;

    const result = await this.conexao.query(sql, [loginData.vl_email]);

    if (result.rows.length === 0) {
      throw new Error('Email ou senha inválidos.');
    }

    const usuario = result.rows[0];

    // Verifica a senha. Senhas novas usam hash scrypt; senhas legadas (AES
    // reversível) são validadas e migradas para hash no primeiro login.
    let senhaValida = false;

    if (isHashed(usuario.vl_senha)) {
      senhaValida = verifyPassword(loginData.vl_senha, usuario.vl_senha);
    } else {
      senhaValida = encrypt(loginData.vl_senha) === usuario.vl_senha;
      if (senhaValida) {
        // Migração best-effort: se a coluna ainda não foi ampliada para
        // VARCHAR(255), o UPDATE falha — mas isso não deve derrubar o login.
        try {
          await this.conexao.query(
            'UPDATE tb_usuario_dn SET vl_senha = $1 WHERE id_usuario = $2',
            [hashPassword(loginData.vl_senha), usuario.id_usuario]
          );
        } catch (erro) {
          console.warn('Falha ao migrar senha para hash (rode o ALTER TABLE vl_senha):', erro);
        }
      }
    }

    if (!senhaValida) {
      throw new Error('Email ou senha inválidos.');
    }

    // Remove a senha do retorno e anexa o token de sessão
    delete usuario.vl_senha;
    usuario.token = gerarToken(usuario.id_usuario);

    // Define os dados de retorno
    this.banco.setDados(1, usuario);
  }

  async verificarEmailExiste(vl_email: String): Promise<void> {
    if (!vl_email) {
      throw new Error('Email não fornecido.');
    }

    const sql = 'SELECT id_usuario, nm_usuario, nm_sobrenome, vl_email, vl_foto, vl_foto_capa FROM tb_usuario_dn WHERE vl_email = $1';
    const result = await this.conexao.query(sql, [vl_email]);

    // Anexa um token de sessão quando o usuário existe (login via Google),
    // para que ele também passe pelos endpoints protegidos.
    const linhas = result.rows.map((u: any) => ({
      ...u,
      token: gerarToken(Number(u.id_usuario)),
    }));

    this.banco.setDados(linhas.length, linhas);
  }

  /**
   * Login OU cadastro via Google: se o email já existe, retorna o usuário;
   * se não, cria a conta a partir dos dados do Google (sem CPF, com senha
   * aleatória — o acesso é pelo Google). Sempre devolve um token de sessão.
   */
  async loginOuCadastroGoogle(dados: {
    vl_email: string;
    nm_usuario?: string;
    nm_sobrenome?: string;
    vl_foto?: string | null;
  }): Promise<void> {
    if (!dados.vl_email || !this.emailPermitido(dados.vl_email)) {
      throw new Error('Email do Google inválido.');
    }

    const sqlBusca = `
      SELECT id_usuario, nm_usuario, nm_sobrenome, vl_email, vl_foto, vl_foto_capa, fl_anfitriao
      FROM tb_usuario_dn WHERE vl_email = $1
    `;
    let result = await this.conexao.query(sqlBusca, [dados.vl_email]);

    let usuario: any;
    if (result.rows.length > 0) {
      usuario = result.rows[0];
    } else {
      // Cria a conta a partir do Google
      const sqlSeq = 'SELECT id_sequence FROM tb_sequence_dn ORDER BY id_sequence DESC LIMIT 1';
      const seqResult = await this.conexao.query(sqlSeq);
      const maiorId = (seqResult.rows.length > 0 ? seqResult.rows[0].id_sequence : 0) + 1;
      await this.conexao.query(
        'INSERT INTO tb_sequence_dn (id_sequence, nm_sequence) VALUES ($1, $2)',
        [maiorId, 'U']
      );

      const senhaAleatoria = hashPassword(crypto.randomBytes(24).toString('hex'));

      await this.conexao.query(
        `INSERT INTO tb_usuario_dn
         (id_usuario, nu_cpf, nm_usuario, fl_anfitriao, vl_email, nm_sobrenome, vl_senha, vl_foto)
         VALUES ($1, NULL, $2, 'false', $3, $4, $5, $6)`,
        [
          maiorId,
          dados.nm_usuario && dados.nm_usuario.trim() !== '' ? dados.nm_usuario : 'Usuário',
          dados.vl_email,
          dados.nm_sobrenome || '',
          senhaAleatoria,
          dados.vl_foto || null,
        ]
      );

      result = await this.conexao.query(sqlBusca, [dados.vl_email]);
      usuario = result.rows[0];
    }

    usuario.token = gerarToken(Number(usuario.id_usuario));
    this.banco.setDados(1, usuario);
  }

  /**
   * Lista todos os usuários
   */
  async getUsuarios(): Promise<void> {
    const sql = `
      SELECT id_usuario, nm_usuario, nm_sobrenome, vl_foto, fl_anfitriao
      FROM tb_usuario_dn
    `;
    const result = await this.conexao.query(sql);
    
    this.banco.setDados(result.rows.length, result.rows);
    
    if (result.rows.length === 0) {
      throw new Error('Usuario nao Localizado');
    }
  }

  /**
   * Busca um usuário específico pelo ID
   */
  async getUsuario(id_usuario: number): Promise<void> {
    const sql = `
      SELECT id_usuario, nm_usuario, nm_sobrenome, vl_foto, vl_foto_capa, fl_anfitriao
      FROM tb_usuario_dn
      WHERE id_usuario = $1
    `;
    const result = await this.conexao.query(sql, [id_usuario]);
    
    this.banco.setDados(result.rows.length, result.rows);
    
    if (result.rows.length === 0) {
      throw new Error('Usuario nao Localizado');
    }
  }

  /**
   * Cria um novo usuário
   */
  async createUsuario(dados: {
    nu_cpf: string;
    nm_usuario: string;
    vl_email: string;
    nm_sobrenome: string;
    vl_senha: string;
    vl_foto?: string | null;
  }): Promise<void> {
    if (!this.emailPermitido(dados.vl_email)) {
      throw new Error('Informe um email com @ e domínio.');
    }

    // Verifica se já existe CPF ou Email
    const sqlCheck = `
      SELECT COUNT(*) as total 
      FROM tb_usuario_dn 
      WHERE nu_cpf = $1 OR vl_email = $2
    `;
    const checkResult = await this.conexao.query(sqlCheck, [dados.nu_cpf, dados.vl_email]);
    
    if (parseInt(checkResult.rows[0].total) > 0) {
      throw new Error('Já existe um usuário com este CPF ou email.');
    }

    // Gera o próximo ID usando a tabela de sequência
    const sqlSeq = 'SELECT id_sequence FROM tb_sequence_dn ORDER BY id_sequence DESC LIMIT 1';
    const seqResult = await this.conexao.query(sqlSeq);
    
    let maiorId = 1;
    if (seqResult.rows.length > 0) {
      maiorId = seqResult.rows[0].id_sequence + 1;
    }

    // Atualiza a sequência
    const sqlInsertSeq = 'INSERT INTO tb_sequence_dn (id_sequence, nm_sequence) VALUES ($1, $2)';
    await this.conexao.query(sqlInsertSeq, [maiorId, 'U']);

    // Gera o hash da senha (scrypt, unidirecional)
    const senhaHash = hashPassword(dados.vl_senha);

    // Insere o usuário
    const sqlUser = `
      INSERT INTO tb_usuario_dn
      (id_usuario, nu_cpf, nm_usuario, fl_anfitriao, vl_email, nm_sobrenome, vl_senha, vl_foto)
      VALUES ($1, $2, $3, 'false', $4, $5, $6, $7)
    `;

    await this.conexao.query(sqlUser, [
      maiorId,
      dados.nu_cpf,
      dados.nm_usuario,
      dados.vl_email,
      dados.nm_sobrenome,
      senhaHash,
      dados.vl_foto || null,
    ]);

    // Retorna o usuário criado
    const sqlUsuarioCriado = `
      SELECT id_usuario, nm_usuario, nm_sobrenome, vl_email, vl_foto, fl_anfitriao
      FROM tb_usuario_dn
      WHERE id_usuario = $1
    `;
    const usuarioCriado = await this.conexao.query(sqlUsuarioCriado, [maiorId]);

    if (usuarioCriado.rows.length === 0) {
      throw new Error('Não foi possível criar o usuario');
    }

    this.banco.setDados(1, usuarioCriado.rows);
  }

  /**
   * Deleta um usuário
   */
  async deleteUsuario(id_usuario: number): Promise<void> {
    const sql = 'DELETE FROM tb_usuario_dn WHERE id_usuario = $1';
    await this.conexao.query(sql, [id_usuario]);
    
    this.banco.setDados(1, { Mensagem: 'Deletado com sucesso' });
  }

  /**
   * Atualiza foto de perfil
   */
  async atualizarFotoPerfil(id_usuario: number, vl_foto: string): Promise<void> {
    const sql = 'UPDATE tb_usuario_dn SET vl_foto = $1 WHERE id_usuario = $2';
    await this.conexao.query(sql, [vl_foto, id_usuario]);

    this.banco.setDados(1, { Mensagem: 'Foto atualizada com sucesso' });
  }

  /**
   * Atualiza foto de capa
   */
  async atualizarFotoCapa(id_usuario: number, vl_foto_capa: string): Promise<void> {
    const sql = 'UPDATE tb_usuario_dn SET vl_foto_capa = $1 WHERE id_usuario = $2';
    await this.conexao.query(sql, [vl_foto_capa, id_usuario]);

    this.banco.setDados(1, { Mensagem: 'Foto de capa atualizada com sucesso' });
  }
}

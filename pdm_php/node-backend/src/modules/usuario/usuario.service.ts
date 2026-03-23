import { BaseService } from '../../database/BaseService';
import { Database } from '../../database/Database';
import { LoginData } from '../../types';
import { encrypt } from '../../utils/encryption';

/**
 * UsuarioService - Equivalente ao UsuarioService.php
 */
export class UsuarioService extends BaseService {
  constructor(banco: Database) {
    super(banco);
  }

  /**
   * Login do usuário
   */
  async loginUsuario(loginData: LoginData): Promise<void> {
    if (!loginData.vl_email || !loginData.vl_senha) {
      throw new Error('Email ou senha não fornecidos.');
    }

    // Criptografa a senha para comparar com o banco
    const senhaCriptografada = encrypt(loginData.vl_senha);

    // Busca usuário no banco
    const sql = `
      SELECT id_usuario, nm_usuario, nm_sobrenome, vl_email, vl_senha, vl_foto 
      FROM tb_usuario_dn 
      WHERE vl_email = $1
    `;

    const result = await this.conexao.query(sql, [loginData.vl_email]);

    if (result.rows.length === 0) {
      throw new Error('Email ou senha inválidos.');
    }

    const usuario = result.rows[0];

    // Verifica se a senha está correta
    if (usuario.vl_senha !== senhaCriptografada) {
      throw new Error('Email ou senha inválidos.');
    }

    // Remove a senha do retorno
    delete usuario.vl_senha;

    // Define os dados de retorno
    this.banco.setDados(1, usuario);
  }

  /**
   * Lista todos os usuários
   */
  async getUsuarios(): Promise<void> {
    const sql = 'SELECT * FROM tb_usuario_dn';
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
    const sql = 'SELECT * FROM tb_usuario_dn WHERE id_usuario = $1';
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

    // Criptografa a senha
    const senhaCriptografada = encrypt(dados.vl_senha);

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
      senhaCriptografada,
      dados.vl_foto || null,
    ]);

    // Retorna o usuário criado
    const sqlUsuarioCriado = 'SELECT * FROM tb_usuario_dn WHERE id_usuario = $1';
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
}

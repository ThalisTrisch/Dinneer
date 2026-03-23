import { BaseService } from '../../database/BaseService';
import { Database } from '../../database/Database';

/**
 * LocalService - Equivalente ao LocalService.php
 */
export class LocalService extends BaseService {
  constructor(banco: Database) {
    super(banco);
  }

  /**
   * Busca um local específico pelo ID
   */
  async getLocal(id_local: number): Promise<void> {
    const sql = 'SELECT * FROM tb_local_dn WHERE id_local = $1';
    const result = await this.conexao.query(sql, [id_local]);
    
    this.banco.setDados(result.rows.length, result.rows);
    
    if (result.rows.length === 0) {
      this.banco.setDados(0, []);
    }
  }

  /**
   * Lista todos os locais
   */
  async getLocais(): Promise<void> {
    const sql = 'SELECT * FROM tb_local_dn';
    const result = await this.conexao.query(sql);
    
    this.banco.setDados(result.rows.length, result.rows);
    
    if (result.rows.length === 0) {
      this.banco.setDados(0, []);
    }
  }

  /**
   * Busca os locais de um usuário específico
   * Ordena pelo ID decrescente (último criado primeiro)
   */
  async getMeusLocais(id_usuario: number): Promise<void> {
    const sql = 'SELECT * FROM tb_local_dn WHERE id_usuario = $1 ORDER BY id_local DESC';
    const result = await this.conexao.query(sql, [id_usuario]);
    
    this.banco.setDados(result.rows.length, result.rows);
    
    if (result.rows.length === 0) {
      this.banco.setDados(0, []);
    }
  }

  /**
   * Cria um novo local
   */
  async createLocal(dados: {
    nu_cep: string;
    nu_casa: string;
    id_usuario: number;
    nu_cnpj?: string | null;
    dc_complemento?: string | null;
  }): Promise<void> {
    // Gera o próximo ID usando a tabela de sequência
    const sqlSeq = 'SELECT id_sequence FROM tb_sequence_dn ORDER BY id_sequence DESC LIMIT 1';
    const seqResult = await this.conexao.query(sqlSeq);
    
    let maiorId = 1;
    if (seqResult.rows.length > 0) {
      maiorId = seqResult.rows[0].id_sequence + 1;
    }

    // Atualiza a sequência
    const sqlInsertSeq = 'INSERT INTO tb_sequence_dn (id_sequence, nm_sequence) VALUES ($1, $2)';
    await this.conexao.query(sqlInsertSeq, [maiorId, 'L']);

    // Insere o local
    const sqlLocal = `
      INSERT INTO tb_local_dn 
      (id_local, id_usuario, nu_cep, nu_casa, nu_cnpj, dc_complemento) 
      VALUES ($1, $2, $3, $4, $5, $6)
    `;
    
    await this.conexao.query(sqlLocal, [
      maiorId,
      dados.id_usuario,
      dados.nu_cep,
      dados.nu_casa,
      dados.nu_cnpj || null,
      dados.dc_complemento || null,
    ]);

    this.banco.setDados(1, { Mensagem: 'Local criado com sucesso' });
  }

  /**
   * Deleta um local
   * Remove dependências em cascata (Encontro e Cardapio)
   */
  async deleteLocal(id_local: number): Promise<void> {
    // Limpeza de dependências (cascata manual)
    await this.conexao.query('DELETE FROM tb_encontro_dn WHERE id_local = $1', [id_local]);
    await this.conexao.query('DELETE FROM tb_cardapio_dn WHERE id_local = $1', [id_local]);

    // Deleta o local
    const sql = 'DELETE FROM tb_local_dn WHERE id_local = $1';
    await this.conexao.query(sql, [id_local]);
    
    this.banco.setDados(1, { Mensagem: 'Deletado com sucesso' });
  }
}

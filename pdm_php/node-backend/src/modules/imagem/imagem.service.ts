import { BaseService } from '../../database/BaseService';
import { Database } from '../../database/Database';

/**
 * ImagemService - Equivalente ao imagemService.php
 * Gerencia URLs de imagens associadas a sequences
 */
export class ImagemService extends BaseService {
  constructor(banco: Database) {
    super(banco);
  }

  /**
   * Busca uma imagem pelo ID
   */
  async getImagem(id_imagem: number): Promise<void> {
    const sql = `
      SELECT * 
      FROM tb_imagem_dn as A, tb_sequence_dn as B 
      WHERE B.id_sequence = A.id_sequence 
      AND B.id_sequence = $1
    `;

    const result = await this.conexao.query(sql, [id_imagem]);

    this.banco.setDados(result.rows.length, result.rows);

    if (result.rows.length === 0) {
      this.banco.setDados(0, []);
    }
  }

  /**
   * Cria uma nova imagem (registra URL)
   */
  async createImagem(id_sequence: number, vl_url: string): Promise<void> {
    const sql = 'INSERT INTO tb_imagem_dn (vl_url, id_sequence) VALUES ($1, $2)';

    await this.conexao.query(sql, [vl_url, id_sequence]);

    this.banco.setDados(1, { Mensagem: 'Imagem criada com sucesso!' });
  }

  /**
   * Deleta uma imagem
   */
  async deleteImagem(id_imagem: number): Promise<void> {
    const sql = 'DELETE FROM tb_imagem_dn WHERE id_imagem = $1';

    const result = await this.conexao.query(sql, [id_imagem]);

    if (result.rowCount === 0) {
      throw new Error('Não foi possível deletar a imagem');
    }

    this.banco.setDados(1, { Mensagem: 'Deletado com sucesso' });
  }
}

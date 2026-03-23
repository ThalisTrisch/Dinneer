import { BaseService } from '../../database/BaseService';
import { Database } from '../../database/Database';

/**
 * AvaliacaoService - Equivalente ao AvaliacaoService.php
 * Gerencia avaliações de encontros
 */
export class AvaliacaoService extends BaseService {
  constructor(banco: Database) {
    super(banco);
  }

  /**
   * Cria uma avaliação para um encontro
   * Cada usuário pode avaliar múltiplos critérios (id_avaliacao) de um encontro
   */
  async createAvaliacao(
    id_usuario: number,
    id_encontro: number,
    vl_avaliacao: number,
    id_avaliacao: number
  ): Promise<void> {
    // Verifica se já avaliou este critério
    const check = await this.conexao.query(
      'SELECT * FROM tb_avaliacao_encontro_dn WHERE id_usuario = $1 AND id_encontro = $2 AND id_avaliacao = $3',
      [id_usuario, id_encontro, id_avaliacao]
    );

    if (check.rows.length > 0) {
      throw new Error('Você já avaliou este critério para este jantar.');
    }

    // Insere avaliação
    const sql = `
      INSERT INTO tb_avaliacao_encontro_dn (id_usuario, id_encontro, vl_avaliacao, id_avaliacao) 
      VALUES ($1, $2, $3, $4)
    `;

    await this.conexao.query(sql, [id_usuario, id_encontro, parseInt(vl_avaliacao.toString()), id_avaliacao]);

    this.banco.setDados(1, { Mensagem: 'Avaliação registrada!' });
  }

  /**
   * Lista os tipos de avaliação disponíveis
   * Ex: Comida, Atendimento, Ambiente, etc.
   */
  async getTiposAvaliacao(): Promise<void> {
    const sql = 'SELECT * FROM tb_tipo_avaliacao_dn';
    const result = await this.conexao.query(sql);

    this.banco.setDados(result.rows.length, result.rows);

    if (result.rows.length === 0) {
      this.banco.setDados(0, []);
    }
  }

  /**
   * Calcula a média de avaliações de um anfitrião
   * Considera todas as avaliações dos encontros que ele criou
   */
  async getMediaAvaliacaoUsuario(id_anfitriao: number): Promise<void> {
    const sql = `
      SELECT 
        COALESCE(AVG(av.vl_avaliacao), 0) as media_geral, 
        COUNT(av.vl_avaliacao) as total_avaliacoes 
      FROM tb_usuario_dn u
      LEFT JOIN tb_local_dn l ON u.id_usuario = l.id_usuario
      LEFT JOIN tb_encontro_dn e ON l.id_local = e.id_local
      LEFT JOIN tb_avaliacao_encontro_dn av ON e.id_encontro = av.id_encontro
      WHERE u.id_usuario = $1
    `;

    const result = await this.conexao.query(sql, [id_anfitriao]);
    const resultado = result.rows[0];

    const media = resultado.media_geral ? Math.round(parseFloat(resultado.media_geral) * 10) / 10 : 0;
    const total = resultado.total_avaliacoes ? parseInt(resultado.total_avaliacoes) : 0;

    this.banco.setDados(1, {
      media: media,
      total: total,
    });
  }
}

import { BaseService } from '../../database/BaseService';
import { Database } from '../../database/Database';

/**
 * CardapioService - Equivalente ao CardapioService.php
 * Gerencia cardápios e a criação completa de jantares (Local + Cardapio + Encontro)
 */
export class CardapioService extends BaseService {
  constructor(banco: Database) {
    super(banco);
  }

  /**
   * Busca um cardápio específico pelo ID
   */
  async getCardapio(id_cardapio: number): Promise<void> {
    const sql = 'SELECT * FROM tb_cardapio_dn WHERE id_cardapio = $1';
    const result = await this.conexao.query(sql, [id_cardapio]);
    
    this.banco.setDados(result.rows.length, result.rows);
    
    if (result.rows.length === 0) {
      this.banco.setDados(0, []);
    }
  }

  /**
   * Lista cardápios disponíveis com informações completas
   * Inclui dados do anfitrião, local, encontro e vagas
   */
  async getCardapiosDisponiveis(): Promise<void> {
    const sql = `
      SELECT 
        c.id_usuario,
        c.nm_usuario || ' ' || c.nm_sobrenome as nm_usuario_anfitriao,
        c.vl_foto as vl_foto_usuario,
        a.id_cardapio,
        a.nm_cardapio,
        a.ds_cardapio,
        a.preco_refeicao,
        a.vl_foto_cardapio,
        d.hr_encontro,
        d.nu_max_convidados,
        d.id_encontro,
        a.id_local,
        b.nu_cep,
        b.nu_casa,
        (
          SELECT COALESCE(SUM(1 + eu.nu_dependentes), 0)
          FROM tb_encontro_usuario_dn eu
          WHERE eu.id_encontro = d.id_encontro
        ) as nu_convidados_confirmados
      FROM tb_cardapio_dn a 
      INNER JOIN tb_local_dn b ON a.id_local = b.id_local
      INNER JOIN tb_usuario_dn c ON b.id_usuario = c.id_usuario
      INNER JOIN tb_encontro_dn d ON b.id_local = d.id_local
      WHERE d.hr_encontro > now()
      ORDER BY d.hr_encontro ASC
    `;
    
    const result = await this.conexao.query(sql);
    
    this.banco.setDados(result.rows.length, result.rows);
    
    if (result.rows.length === 0) {
      this.banco.setDados(0, []);
    }
  }

  /**
   * Cria um jantar completo (Local + Cardapio + Encontro)
   * Usa transação para garantir consistência
   */
  async createJantarCompleto(dados: {
    id_usuario: number;
    nm_cardapio: string;
    ds_cardapio: string;
    preco_refeicao: number;
    hr_encontro: string;
    nu_max_convidados: number;
    nu_cep?: string;
    nu_casa?: string;
    vl_foto?: string;
    id_local?: number | string;
  }): Promise<void> {
    try {
      await this.conexao.query('BEGIN');

      let idLocal = 0;

      // Verifica se deve usar local existente ou criar novo
      if (dados.id_local && dados.id_local !== 'novo') {
        // Converte para número se for string
        idLocal = typeof dados.id_local === 'string' ? parseInt(dados.id_local) : dados.id_local;
        
        // Verifica se o local existe
        const checkLocal = await this.conexao.query('SELECT id_local FROM tb_local_dn WHERE id_local = $1', [idLocal]);
        if (checkLocal.rows.length === 0) {
          throw new Error('Local não encontrado');
        }
      } else {
        // Cria novo local
        const sqlSeqL = 'SELECT id_sequence FROM tb_sequence_dn ORDER BY id_sequence DESC LIMIT 1';
        const resSeq = await this.conexao.query(sqlSeqL);
        idLocal = (resSeq.rows.length > 0 ? resSeq.rows[0].id_sequence : 0) + 1;

        await this.conexao.query('INSERT INTO tb_sequence_dn (id_sequence, nm_sequence) VALUES ($1, $2)', [idLocal, 'L']);

        const sqlLocal = 'INSERT INTO tb_local_dn (id_local, id_usuario, nu_cep, nu_casa) VALUES ($1, $2, $3, $4)';
        await this.conexao.query(sqlLocal, [idLocal, dados.id_usuario, dados.nu_cep, dados.nu_casa]);
      }

      // Cria cardápio
      const sqlSeqC = 'SELECT id_sequence FROM tb_sequence_dn ORDER BY id_sequence DESC LIMIT 1';
      const resSeqC = await this.conexao.query(sqlSeqC);
      const idCardapio = (resSeqC.rows.length > 0 ? resSeqC.rows[0].id_sequence : 0) + 1;

      await this.conexao.query('INSERT INTO tb_sequence_dn (id_sequence, nm_sequence) VALUES ($1, $2)', [idCardapio, 'C']);

      const sqlCard = `
        INSERT INTO tb_cardapio_dn (id_cardapio, id_local, nm_cardapio, ds_cardapio, preco_refeicao, vl_foto_cardapio) 
        VALUES ($1, $2, $3, $4, $5, $6)
      `;
      await this.conexao.query(sqlCard, [
        idCardapio,
        idLocal,
        dados.nm_cardapio,
        dados.ds_cardapio,
        dados.preco_refeicao,
        dados.vl_foto && dados.vl_foto.trim() !== '' ? dados.vl_foto : null
      ]);

      // Cria encontro
      const idEncontro = idCardapio + 1;
      await this.conexao.query('INSERT INTO tb_sequence_dn (id_sequence, nm_sequence) VALUES ($1, $2)', [idEncontro, 'E']);

      const sqlEnc = `
        INSERT INTO tb_encontro_dn (id_encontro, id_local, id_cardapio, hr_encontro, nu_max_convidados, fl_anfitriao_confirma) 
        VALUES ($1, $2, $3, $4, $5, 'true')
      `;
      await this.conexao.query(sqlEnc, [
        idEncontro,
        idLocal,
        idCardapio,
        dados.hr_encontro,
        dados.nu_max_convidados
      ]);

      await this.conexao.query('COMMIT');
      this.banco.setDados(1, { Mensagem: 'Jantar criado com sucesso!' });

    } catch (error: any) {
      await this.conexao.query('ROLLBACK');
      throw new Error('Erro ao criar jantar: ' + error.message);
    }
  }

  /**
   * Atualiza um jantar (Cardapio + Encontro + Local)
   */
  async updateJantar(dados: {
    id_cardapio: number;
    nm_cardapio: string;
    ds_cardapio: string;
    preco_refeicao: number;
    hr_encontro: string;
    nu_max_convidados: number;
    nu_cep: string;
    nu_casa: string;
    vl_foto?: string;
  }): Promise<void> {
    try {
      await this.conexao.query('BEGIN');

      // Atualiza cardápio
      const sqlC = `
        UPDATE tb_cardapio_dn SET 
          nm_cardapio = $1, 
          ds_cardapio = $2, 
          preco_refeicao = $3,
          vl_foto_cardapio = $4 
        WHERE id_cardapio = $5
      `;
      await this.conexao.query(sqlC, [
        dados.nm_cardapio,
        dados.ds_cardapio,
        dados.preco_refeicao,
        dados.vl_foto || null,
        dados.id_cardapio
      ]);

      // Atualiza encontro
      const sqlE = `
        UPDATE tb_encontro_dn SET 
          hr_encontro = $1, 
          nu_max_convidados = $2 
        WHERE id_cardapio = $3
      `;
      await this.conexao.query(sqlE, [
        dados.hr_encontro,
        dados.nu_max_convidados,
        dados.id_cardapio
      ]);

      // Atualiza local
      const sqlL = `
        UPDATE tb_local_dn SET 
          nu_cep = $1, 
          nu_casa = $2 
        WHERE id_local = (SELECT id_local FROM tb_cardapio_dn WHERE id_cardapio = $3)
      `;
      await this.conexao.query(sqlL, [
        dados.nu_cep,
        dados.nu_casa,
        dados.id_cardapio
      ]);

      await this.conexao.query('COMMIT');
      this.banco.setDados(1, { Mensagem: 'Jantar atualizado com sucesso!' });

    } catch (error: any) {
      await this.conexao.query('ROLLBACK');
      throw new Error('Erro ao atualizar: ' + error.message);
    }
  }

  /**
   * Deleta um jantar completo (Cardapio + Encontro + Local + relacionamentos)
   */
  async deleteJantar(id_cardapio: number): Promise<void> {
    try {
      await this.conexao.query('BEGIN');

      // Busca id_local do cardápio
      const sqlCardapio = 'SELECT id_local FROM tb_cardapio_dn WHERE id_cardapio = $1';
      const cardapioResult = await this.conexao.query(sqlCardapio, [id_cardapio]);

      if (cardapioResult.rows.length > 0) {
        const idLocal = cardapioResult.rows[0].id_local;

        // Busca encontro relacionado
        const sqlEncontro = 'SELECT id_encontro FROM tb_encontro_dn WHERE id_cardapio = $1';
        const encontroResult = await this.conexao.query(sqlEncontro, [id_cardapio]);

        if (encontroResult.rows.length > 0) {
          const idEncontro = encontroResult.rows[0].id_encontro;

          // Deleta avaliações do encontro
          await this.conexao.query('DELETE FROM tb_avaliacao_encontro_dn WHERE id_encontro = $1', [idEncontro]);

          // Deleta participantes do encontro
          await this.conexao.query('DELETE FROM tb_encontro_usuario_dn WHERE id_encontro = $1', [idEncontro]);

          // Deleta encontro
          await this.conexao.query('DELETE FROM tb_encontro_dn WHERE id_encontro = $1', [idEncontro]);
        }

        // Deleta cardápio
        await this.conexao.query('DELETE FROM tb_cardapio_dn WHERE id_cardapio = $1', [id_cardapio]);

        // Deleta local
        await this.conexao.query('DELETE FROM tb_local_dn WHERE id_local = $1', [idLocal]);
      }

      await this.conexao.query('COMMIT');
      this.banco.setDados(1, { Mensagem: 'Jantar cancelado e excluído.' });

    } catch (error: any) {
      await this.conexao.query('ROLLBACK');
      throw new Error('Erro ao excluir: ' + error.message);
    }
  }
}

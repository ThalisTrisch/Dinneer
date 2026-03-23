import { BaseService } from '../../database/BaseService';
import { Database } from '../../database/Database';

/**
 * EncontroService - Equivalente ao EncontroService.php
 * Gerencia participação em encontros (reservas, confirmações, etc)
 */
export class EncontroService extends BaseService {
  constructor(banco: Database) {
    super(banco);
  }

  /**
   * Adiciona usuário a um encontro (solicita reserva)
   */
  async addUsuarioEncontro(id_usuario: number, id_encontro: number, nu_dependentes: number): Promise<void> {
    // Verifica se já solicitou reserva
    const check = await this.conexao.query(
      'SELECT * FROM tb_encontro_usuario_dn WHERE id_usuario = $1 AND id_encontro = $2',
      [id_usuario, id_encontro]
    );

    if (check.rows.length > 0) {
      throw new Error('Você já solicitou reserva para este jantar.');
    }

    // Insere solicitação com status Pendente
    const sql = `
      INSERT INTO tb_encontro_usuario_dn (id_usuario, id_encontro, nu_dependentes, fl_anfitriao, fl_status) 
      VALUES ($1, $2, $3, 'false', 'P')
    `;

    await this.conexao.query(sql, [id_usuario, id_encontro, nu_dependentes]);
    this.banco.setDados(1, { Mensagem: 'Solicitação enviada! Aguarde a aprovação do anfitrião.' });
  }

  /**
   * Aprova uma reserva (anfitrião confirma convidado)
   */
  async aprovarReserva(id_encontro: number, id_usuario_convidado: number): Promise<void> {
    // Busca capacidade do encontro
    const sqlCapacidade = `
      SELECT 
        e.nu_max_convidados,
        (SELECT COALESCE(SUM(1 + eu.nu_dependentes), 0) 
         FROM tb_encontro_usuario_dn eu 
         WHERE eu.id_encontro = e.id_encontro AND eu.fl_status = 'C') as total_confirmados
      FROM tb_encontro_dn e
      WHERE e.id_encontro = $1
    `;
    const resCap = await this.conexao.query(sqlCapacidade, [id_encontro]);
    const dados = resCap.rows[0];

    // Busca dependentes do convidado
    const sqlConv = 'SELECT nu_dependentes FROM tb_encontro_usuario_dn WHERE id_encontro = $1 AND id_usuario = $2';
    const resConv = await this.conexao.query(sqlConv, [id_encontro, id_usuario_convidado]);
    const dadosConv = resConv.rows[0];

    const lugaresNecessarios = 1 + (dadosConv?.nu_dependentes || 0);
    const lugaresOcupados = parseInt(dados.total_confirmados);
    const max = parseInt(dados.nu_max_convidados);

    // Verifica se há vagas
    if ((lugaresOcupados + lugaresNecessarios) > max) {
      throw new Error('Não há vagas suficientes para aprovar este grupo.');
    }

    // Atualiza status para Confirmado
    const sql = 'UPDATE tb_encontro_usuario_dn SET fl_status = $1 WHERE id_encontro = $2 AND id_usuario = $3';
    await this.conexao.query(sql, ['C', id_encontro, id_usuario_convidado]);

    this.banco.setDados(1, { Mensagem: 'Convidado confirmado com sucesso!' });
  }

  /**
   * Rejeita uma reserva (anfitrião recusa convidado)
   */
  async rejeitarReserva(id_encontro: number, id_usuario_convidado: number): Promise<void> {
    const sql = 'DELETE FROM tb_encontro_usuario_dn WHERE id_encontro = $1 AND id_usuario = $2';
    await this.conexao.query(sql, [id_encontro, id_usuario_convidado]);

    this.banco.setDados(1, { Mensagem: 'Solicitação recusada.' });
  }

  /**
   * Lista participantes de um encontro
   */
  async getParticipantes(id_encontro: number): Promise<void> {
    const sql = `
      SELECT 
        u.id_usuario,
        u.nm_usuario || ' ' || u.nm_sobrenome as nome_completo,
        u.vl_foto,
        eu.nu_dependentes,
        eu.fl_status
      FROM tb_encontro_usuario_dn eu
      INNER JOIN tb_usuario_dn u ON eu.id_usuario = u.id_usuario
      WHERE eu.id_encontro = $1 AND eu.fl_anfitriao = 'false'
      ORDER BY eu.fl_status DESC, u.nm_usuario ASC
    `;

    const result = await this.conexao.query(sql, [id_encontro]);

    this.banco.setDados(result.rows.length, result.rows);

    if (result.rows.length === 0) {
      this.banco.setDados(0, []);
    }
  }

  /**
   * Verifica se usuário já tem reserva em um encontro
   */
  async verificarReserva(id_usuario: number, id_encontro: number): Promise<void> {
    const sql = 'SELECT fl_status FROM tb_encontro_usuario_dn WHERE id_usuario = $1 AND id_encontro = $2';
    const result = await this.conexao.query(sql, [id_usuario, id_encontro]);

    if (result.rows.length > 0) {
      this.banco.setDados(1, { ja_reservou: true, status: result.rows[0].fl_status });
    } else {
      this.banco.setDados(0, { ja_reservou: false, status: null });
    }
  }

  /**
   * Cancela participação de usuário em encontro
   */
  async deleteUsuarioEncontro(id_usuario: number, id_encontro: number): Promise<void> {
    const sql = 'DELETE FROM tb_encontro_usuario_dn WHERE id_usuario = $1 AND id_encontro = $2';
    await this.conexao.query(sql, [id_usuario, id_encontro]);

    this.banco.setDados(1, { Mensagem: 'Reserva cancelada.' });
  }

  /**
   * Lista reservas do usuário (como convidado)
   */
  async getMinhasReservas(id_usuario: number): Promise<void> {
    const sql = `
      SELECT 
        c.id_cardapio,
        c.nm_cardapio,
        c.ds_cardapio,
        c.preco_refeicao,
        c.vl_foto_cardapio,
        e.id_encontro,
        e.hr_encontro,
        e.nu_max_convidados,
        l.id_local,
        l.nu_cep,
        l.nu_casa,
        u_host.id_usuario,
        u_host.nm_usuario || ' ' || u_host.nm_sobrenome as nm_usuario_anfitriao,
        u_host.vl_foto,
        eu.fl_status,
        (SELECT COALESCE(SUM(1 + eu_count.nu_dependentes), 0)
         FROM tb_encontro_usuario_dn eu_count
         WHERE eu_count.id_encontro = e.id_encontro) as nu_convidados_confirmados
      FROM tb_encontro_usuario_dn eu
      INNER JOIN tb_encontro_dn e ON eu.id_encontro = e.id_encontro
      INNER JOIN tb_cardapio_dn c ON e.id_cardapio = c.id_cardapio
      INNER JOIN tb_local_dn l ON c.id_local = l.id_local
      INNER JOIN tb_usuario_dn u_host ON l.id_usuario = u_host.id_usuario
      WHERE eu.id_usuario = $1
      ORDER BY e.hr_encontro DESC
    `;

    const result = await this.conexao.query(sql, [id_usuario]);

    this.banco.setDados(result.rows.length, result.rows);

    if (result.rows.length === 0) {
      this.banco.setDados(0, []);
    }
  }

  /**
   * Lista jantares criados pelo usuário (como anfitrião)
   */
  async getMeusJantaresCriados(id_usuario: number): Promise<void> {
    const sql = `
      SELECT 
        c.id_cardapio,
        c.nm_cardapio,
        c.ds_cardapio,
        c.preco_refeicao,
        c.vl_foto_cardapio,
        e.id_encontro,
        e.hr_encontro,
        e.nu_max_convidados,
        l.id_local,
        l.nu_cep,
        l.nu_casa,
        u.id_usuario,
        u.nm_usuario || ' ' || u.nm_sobrenome as nm_usuario_anfitriao,
        u.vl_foto as vl_foto_usuario,
        (SELECT COALESCE(SUM(1 + eu_count.nu_dependentes), 0)
         FROM tb_encontro_usuario_dn eu_count
         WHERE eu_count.id_encontro = e.id_encontro AND eu_count.fl_status = 'C') as nu_convidados_confirmados,
        (SELECT COUNT(*)
         FROM tb_encontro_usuario_dn eu_pend
         WHERE eu_pend.id_encontro = e.id_encontro AND eu_pend.fl_status = 'P') as nu_solicitacoes_pendentes
      FROM tb_cardapio_dn c
      INNER JOIN tb_local_dn l ON c.id_local = l.id_local
      INNER JOIN tb_encontro_dn e ON c.id_cardapio = e.id_cardapio
      INNER JOIN tb_usuario_dn u ON l.id_usuario = u.id_usuario
      WHERE l.id_usuario = $1
      ORDER BY e.hr_encontro DESC
    `;

    const result = await this.conexao.query(sql, [id_usuario]);

    this.banco.setDados(result.rows.length, result.rows);

    if (result.rows.length === 0) {
      this.banco.setDados(0, []);
    }
  }
}

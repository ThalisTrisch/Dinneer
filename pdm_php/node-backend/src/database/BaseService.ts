import { Pool } from 'pg';
import { Database } from './Database';

/**
 * Classe BaseService - Equivalente ao InstanciaBanco.php
 * Classe base para todos os Services
 */
export abstract class BaseService {
  protected banco: Database;
  protected conexao: Pool;

  constructor(banco: Database) {
    this.banco = banco;
    this.conexao = banco.getConexao();
  }
}

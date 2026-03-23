import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import { CardapioService } from '../../src/modules/cardapio/cardapio.service';
import { Database } from '../../src/database/Database';

describe('CardapioService - Integration Tests', () => {
  let cardapioService: CardapioService;
  let mockDatabase: jest.Mocked<Database>;
  let mockConexao: any;

  beforeEach(() => {
    // Mock da conexão do banco
    mockConexao = {
      query: jest.fn(),
    };

    // Mock do Database
    mockDatabase = {
      getConexao: jest.fn().mockReturnValue(mockConexao),
      setDados: jest.fn(),
      getDados: jest.fn(),
      setMensagem: jest.fn(),
      getMensagem: jest.fn(),
    } as any;

    cardapioService = new CardapioService(mockDatabase);
  });

  describe('getCardapio', () => {
    it('deve buscar um cardápio por ID', async () => {
      // Arrange
      const cardapioMock = {
        id_cardapio: 1,
        id_local: 10,
        nm_cardapio: 'Jantar Italiano',
        ds_cardapio: 'Massa caseira',
        preco_refeicao: 50.00,
        vl_foto_cardapio: null,
      };

      mockConexao.query.mockResolvedValueOnce({
        rows: [cardapioMock],
      });

      // Act
      await cardapioService.getCardapio(1);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith(
        'SELECT * FROM tb_cardapio_dn WHERE id_cardapio = $1',
        [1]
      );
      expect(mockDatabase.setDados).toHaveBeenCalledWith(1, [cardapioMock]);
    });

    it('deve retornar vazio quando cardápio não existe', async () => {
      // Arrange
      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await cardapioService.getCardapio(999);

      // Assert
      expect(mockDatabase.setDados).toHaveBeenCalledWith(0, []);
    });
  });

  describe('getCardapiosDisponiveis', () => {
    it('deve listar cardápios disponíveis com informações completas', async () => {
      // Arrange
      const cardapiosMock = [
        {
          id_usuario: 5,
          nm_usuario_anfitriao: 'João Silva',
          vl_foto_usuario: null,
          id_cardapio: 1,
          nm_cardapio: 'Jantar Italiano',
          ds_cardapio: 'Massa caseira',
          preco_refeicao: 50.00,
          vl_foto_cardapio: null,
          hr_encontro: '2026-12-31 19:00:00',
          nu_max_convidados: 10,
          id_encontro: 1,
          id_local: 10,
          nu_cep: '12345678',
          nu_casa: '100',
          nu_convidados_confirmados: 3,
        },
      ];

      mockConexao.query.mockResolvedValueOnce({
        rows: cardapiosMock,
      });

      // Act
      await cardapioService.getCardapiosDisponiveis();

      // Assert
      expect(mockConexao.query).toHaveBeenCalled();
      expect(mockDatabase.setDados).toHaveBeenCalledWith(1, cardapiosMock);
    });

    it('deve retornar vazio quando não há cardápios disponíveis', async () => {
      // Arrange
      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await cardapioService.getCardapiosDisponiveis();

      // Assert
      expect(mockDatabase.setDados).toHaveBeenCalledWith(0, []);
    });
  });

  describe('createJantarCompleto', () => {
    it('deve criar jantar completo com local novo', async () => {
      // Arrange
      const dadosJantar = {
        id_usuario: 5,
        nm_cardapio: 'Jantar Italiano',
        ds_cardapio: 'Massa caseira',
        preco_refeicao: 50.00,
        hr_encontro: '2026-12-31 19:00:00',
        nu_max_convidados: 10,
        nu_cep: '12345678',
        nu_casa: '100',
        id_local: 'novo',
      };

      mockConexao.query
        .mockResolvedValueOnce({ rows: [] }) // BEGIN
        .mockResolvedValueOnce({ rows: [{ id_sequence: 100 }] }) // SELECT sequence para local
        .mockResolvedValueOnce({ rows: [] }) // INSERT sequence local
        .mockResolvedValueOnce({ rows: [] }) // INSERT local
        .mockResolvedValueOnce({ rows: [{ id_sequence: 101 }] }) // SELECT sequence para cardapio
        .mockResolvedValueOnce({ rows: [] }) // INSERT sequence cardapio
        .mockResolvedValueOnce({ rows: [] }) // INSERT cardapio
        .mockResolvedValueOnce({ rows: [] }) // INSERT sequence encontro
        .mockResolvedValueOnce({ rows: [] }) // INSERT encontro
        .mockResolvedValueOnce({ rows: [] }); // COMMIT

      // Act
      await cardapioService.createJantarCompleto(dadosJantar);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith('BEGIN');
      expect(mockConexao.query).toHaveBeenCalledWith('COMMIT');
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Jantar criado com sucesso!' })
      );
    });

    it('deve criar jantar com local existente', async () => {
      // Arrange
      const dadosJantar = {
        id_usuario: 5,
        nm_cardapio: 'Jantar Italiano',
        ds_cardapio: 'Massa caseira',
        preco_refeicao: 50.00,
        hr_encontro: '2026-12-31 19:00:00',
        nu_max_convidados: 10,
        nu_cep: '12345678',
        nu_casa: '100',
        id_local: 50, // Local existente
      };

      mockConexao.query
        .mockResolvedValueOnce({ rows: [] }) // BEGIN
        .mockResolvedValueOnce({ rows: [{ id_sequence: 100 }] }) // SELECT sequence para cardapio
        .mockResolvedValueOnce({ rows: [] }) // INSERT sequence cardapio
        .mockResolvedValueOnce({ rows: [] }) // INSERT cardapio
        .mockResolvedValueOnce({ rows: [] }) // INSERT sequence encontro
        .mockResolvedValueOnce({ rows: [] }) // INSERT encontro
        .mockResolvedValueOnce({ rows: [] }); // COMMIT

      // Act
      await cardapioService.createJantarCompleto(dadosJantar);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith('BEGIN');
      expect(mockConexao.query).toHaveBeenCalledWith('COMMIT');
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Jantar criado com sucesso!' })
      );
    });

    it('deve fazer rollback em caso de erro', async () => {
      // Arrange
      const dadosJantar = {
        id_usuario: 5,
        nm_cardapio: 'Jantar Italiano',
        ds_cardapio: 'Massa caseira',
        preco_refeicao: 50.00,
        hr_encontro: '2026-12-31 19:00:00',
        nu_max_convidados: 10,
        nu_cep: '12345678',
        nu_casa: '100',
        id_local: 'novo',
      };

      mockConexao.query
        .mockResolvedValueOnce({ rows: [] }) // BEGIN
        .mockRejectedValueOnce(new Error('Database error')); // Erro na query

      // Act & Assert
      await expect(cardapioService.createJantarCompleto(dadosJantar)).rejects.toThrow();
      expect(mockConexao.query).toHaveBeenCalledWith('ROLLBACK');
    });
  });

  describe('updateJantar', () => {
    it('deve atualizar jantar completo', async () => {
      // Arrange
      const dadosAtualizacao = {
        id_cardapio: 1,
        nm_cardapio: 'Jantar Italiano Atualizado',
        ds_cardapio: 'Massa caseira premium',
        preco_refeicao: 75.00,
        hr_encontro: '2026-12-31 20:00:00',
        nu_max_convidados: 15,
        nu_cep: '87654321',
        nu_casa: '200',
        vl_foto: 'https://exemplo.com/foto.jpg',
      };

      mockConexao.query
        .mockResolvedValueOnce({ rows: [] }) // BEGIN
        .mockResolvedValueOnce({ rows: [] }) // UPDATE cardapio
        .mockResolvedValueOnce({ rows: [] }) // UPDATE encontro
        .mockResolvedValueOnce({ rows: [] }) // UPDATE local
        .mockResolvedValueOnce({ rows: [] }); // COMMIT

      // Act
      await cardapioService.updateJantar(dadosAtualizacao);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith('BEGIN');
      expect(mockConexao.query).toHaveBeenCalledWith('COMMIT');
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Jantar atualizado com sucesso!' })
      );
    });

    it('deve fazer rollback em caso de erro na atualização', async () => {
      // Arrange
      const dadosAtualizacao = {
        id_cardapio: 1,
        nm_cardapio: 'Jantar Italiano',
        ds_cardapio: 'Massa caseira',
        preco_refeicao: 50.00,
        hr_encontro: '2026-12-31 19:00:00',
        nu_max_convidados: 10,
        nu_cep: '12345678',
        nu_casa: '100',
      };

      mockConexao.query
        .mockResolvedValueOnce({ rows: [] }) // BEGIN
        .mockRejectedValueOnce(new Error('Update error'));

      // Act & Assert
      await expect(cardapioService.updateJantar(dadosAtualizacao)).rejects.toThrow();
      expect(mockConexao.query).toHaveBeenCalledWith('ROLLBACK');
    });
  });

  describe('deleteJantar', () => {
    it('deve deletar jantar completo com todas as dependências', async () => {
      // Arrange
      mockConexao.query
        .mockResolvedValueOnce({ rows: [] }) // BEGIN
        .mockResolvedValueOnce({ rows: [{ id_local: 10 }] }) // SELECT id_local do cardapio
        .mockResolvedValueOnce({ rows: [{ id_encontro: 1 }] }) // SELECT id_encontro
        .mockResolvedValueOnce({ rows: [] }) // DELETE avaliacoes
        .mockResolvedValueOnce({ rows: [] }) // DELETE participantes
        .mockResolvedValueOnce({ rows: [] }) // DELETE encontro
        .mockResolvedValueOnce({ rows: [] }) // DELETE cardapio
        .mockResolvedValueOnce({ rows: [] }) // DELETE local
        .mockResolvedValueOnce({ rows: [] }); // COMMIT

      // Act
      await cardapioService.deleteJantar(1);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith('BEGIN');
      expect(mockConexao.query).toHaveBeenCalledWith('COMMIT');
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Jantar cancelado e excluído.' })
      );
    });

    it('deve deletar jantar mesmo sem encontro associado', async () => {
      // Arrange
      mockConexao.query
        .mockResolvedValueOnce({ rows: [] }) // BEGIN
        .mockResolvedValueOnce({ rows: [{ id_local: 10 }] }) // SELECT id_local do cardapio
        .mockResolvedValueOnce({ rows: [] }) // SELECT id_encontro (vazio)
        .mockResolvedValueOnce({ rows: [] }) // DELETE cardapio
        .mockResolvedValueOnce({ rows: [] }) // DELETE local
        .mockResolvedValueOnce({ rows: [] }); // COMMIT

      // Act
      await cardapioService.deleteJantar(1);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith('BEGIN');
      expect(mockConexao.query).toHaveBeenCalledWith('COMMIT');
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Jantar cancelado e excluído.' })
      );
    });

    it('deve fazer rollback em caso de erro na deleção', async () => {
      // Arrange
      mockConexao.query
        .mockResolvedValueOnce({ rows: [] }) // BEGIN
        .mockRejectedValueOnce(new Error('Delete error'));

      // Act & Assert
      await expect(cardapioService.deleteJantar(1)).rejects.toThrow();
      expect(mockConexao.query).toHaveBeenCalledWith('ROLLBACK');
    });
  });
});

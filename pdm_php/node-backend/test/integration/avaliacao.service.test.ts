import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import { AvaliacaoService } from '../../src/modules/avaliacao/avaliacao.service';
import { Database } from '../../src/database/Database';

describe('AvaliacaoService - Integration Tests', () => {
  let avaliacaoService: AvaliacaoService;
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

    avaliacaoService = new AvaliacaoService(mockDatabase);
  });

  describe('createAvaliacao', () => {
    it('deve criar uma avaliação com sucesso', async () => {
      // Arrange
      const id_usuario = 5;
      const id_encontro = 10;
      const vl_avaliacao = 4.5;
      const id_avaliacao = 1; // Ex: Comida

      mockConexao.query
        .mockResolvedValueOnce({ rows: [] }) // CHECK se já avaliou
        .mockResolvedValueOnce({ rows: [] }); // INSERT avaliação

      // Act
      await avaliacaoService.createAvaliacao(id_usuario, id_encontro, vl_avaliacao, id_avaliacao);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledTimes(2);
      expect(mockConexao.query).toHaveBeenNthCalledWith(
        1,
        'SELECT * FROM tb_avaliacao_encontro_dn WHERE id_usuario = $1 AND id_encontro = $2 AND id_avaliacao = $3',
        [id_usuario, id_encontro, id_avaliacao]
      );
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Avaliação registrada!' })
      );
    });

    it('deve converter valor decimal para inteiro ao inserir', async () => {
      // Arrange
      const id_usuario = 5;
      const id_encontro = 10;
      const vl_avaliacao = 4.7;
      const id_avaliacao = 1;

      mockConexao.query
        .mockResolvedValueOnce({ rows: [] })
        .mockResolvedValueOnce({ rows: [] });

      // Act
      await avaliacaoService.createAvaliacao(id_usuario, id_encontro, vl_avaliacao, id_avaliacao);

      // Assert
      const insertCall = mockConexao.query.mock.calls[1];
      expect(insertCall[1][2]).toBe(4); // vl_avaliacao convertido para int
    });

    it('deve lançar erro quando usuário já avaliou o critério', async () => {
      // Arrange
      const id_usuario = 5;
      const id_encontro = 10;
      const vl_avaliacao = 5;
      const id_avaliacao = 1;

      mockConexao.query.mockResolvedValueOnce({
        rows: [{ id_usuario: 5, id_encontro: 10, id_avaliacao: 1 }],
      });

      // Act & Assert
      await expect(
        avaliacaoService.createAvaliacao(id_usuario, id_encontro, vl_avaliacao, id_avaliacao)
      ).rejects.toThrow('Você já avaliou este critério para este jantar.');
    });

    it('deve permitir avaliar diferentes critérios do mesmo encontro', async () => {
      // Arrange
      const id_usuario = 5;
      const id_encontro = 10;
      const vl_avaliacao = 4;
      const id_avaliacao_comida = 1;
      const id_avaliacao_ambiente = 2;

      mockConexao.query
        .mockResolvedValueOnce({ rows: [] }) // CHECK critério 1
        .mockResolvedValueOnce({ rows: [] }) // INSERT critério 1
        .mockResolvedValueOnce({ rows: [] }) // CHECK critério 2
        .mockResolvedValueOnce({ rows: [] }); // INSERT critério 2

      // Act
      await avaliacaoService.createAvaliacao(id_usuario, id_encontro, vl_avaliacao, id_avaliacao_comida);
      await avaliacaoService.createAvaliacao(id_usuario, id_encontro, vl_avaliacao, id_avaliacao_ambiente);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledTimes(4);
      expect(mockDatabase.setDados).toHaveBeenCalledTimes(2);
    });
  });

  describe('getTiposAvaliacao', () => {
    it('deve listar todos os tipos de avaliação', async () => {
      // Arrange
      const tiposMock = [
        { id_avaliacao: 1, nm_avaliacao: 'Comida' },
        { id_avaliacao: 2, nm_avaliacao: 'Ambiente' },
        { id_avaliacao: 3, nm_avaliacao: 'Atendimento' },
      ];

      mockConexao.query.mockResolvedValueOnce({
        rows: tiposMock,
      });

      // Act
      await avaliacaoService.getTiposAvaliacao();

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith('SELECT * FROM tb_tipo_avaliacao_dn');
      expect(mockDatabase.setDados).toHaveBeenCalledWith(3, tiposMock);
    });

    it('deve retornar vazio quando não há tipos cadastrados', async () => {
      // Arrange
      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await avaliacaoService.getTiposAvaliacao();

      // Assert
      expect(mockDatabase.setDados).toHaveBeenCalledWith(0, []);
    });
  });

  describe('getMediaAvaliacaoUsuario', () => {
    it('deve calcular média de avaliações do anfitrião', async () => {
      // Arrange
      const id_anfitriao = 5;
      const resultadoMock = {
        media_geral: '4.567',
        total_avaliacoes: '15',
      };

      mockConexao.query.mockResolvedValueOnce({
        rows: [resultadoMock],
      });

      // Act
      await avaliacaoService.getMediaAvaliacaoUsuario(id_anfitriao);

      // Assert
      expect(mockConexao.query).toHaveBeenCalled();
      expect(mockDatabase.setDados).toHaveBeenCalledWith(1, {
        media: 4.6, // Arredondado para 1 casa decimal
        total: 15,
      });
    });

    it('deve retornar zero quando anfitrião não tem avaliações', async () => {
      // Arrange
      const id_anfitriao = 999;
      const resultadoMock = {
        media_geral: null,
        total_avaliacoes: null,
      };

      mockConexao.query.mockResolvedValueOnce({
        rows: [resultadoMock],
      });

      // Act
      await avaliacaoService.getMediaAvaliacaoUsuario(id_anfitriao);

      // Assert
      expect(mockDatabase.setDados).toHaveBeenCalledWith(1, {
        media: 0,
        total: 0,
      });
    });

    it('deve arredondar média para 1 casa decimal', async () => {
      // Arrange
      const id_anfitriao = 5;
      const resultadoMock = {
        media_geral: '4.444',
        total_avaliacoes: '10',
      };

      mockConexao.query.mockResolvedValueOnce({
        rows: [resultadoMock],
      });

      // Act
      await avaliacaoService.getMediaAvaliacaoUsuario(id_anfitriao);

      // Assert
      expect(mockDatabase.setDados).toHaveBeenCalledWith(1, {
        media: 4.4,
        total: 10,
      });
    });

    it('deve calcular média com nota máxima', async () => {
      // Arrange
      const id_anfitriao = 5;
      const resultadoMock = {
        media_geral: '5.0',
        total_avaliacoes: '20',
      };

      mockConexao.query.mockResolvedValueOnce({
        rows: [resultadoMock],
      });

      // Act
      await avaliacaoService.getMediaAvaliacaoUsuario(id_anfitriao);

      // Assert
      expect(mockDatabase.setDados).toHaveBeenCalledWith(1, {
        media: 5.0,
        total: 20,
      });
    });
  });
});

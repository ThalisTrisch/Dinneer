import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import { LocalService } from '../../src/modules/local/local.service';
import { Database } from '../../src/database/Database';

describe('LocalService - Integration Tests', () => {
  let localService: LocalService;
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

    localService = new LocalService(mockDatabase);
  });

  describe('getLocal', () => {
    it('deve buscar um local por ID', async () => {
      // Arrange
      const localMock = {
        id_local: 1,
        id_usuario: 5,
        nu_cep: '12345678',
        nu_casa: '100',
        nu_cnpj: null,
        dc_complemento: 'Apto 101',
      };

      mockConexao.query.mockResolvedValueOnce({
        rows: [localMock],
      });

      // Act
      await localService.getLocal(1);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith(
        'SELECT * FROM tb_local_dn WHERE id_local = $1',
        [1]
      );
      expect(mockDatabase.setDados).toHaveBeenCalledWith(1, [localMock]);
    });

    it('deve retornar vazio quando local não existe', async () => {
      // Arrange
      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await localService.getLocal(999);

      // Assert
      expect(mockDatabase.setDados).toHaveBeenCalledWith(0, []);
    });
  });

  describe('getLocais', () => {
    it('deve listar todos os locais', async () => {
      // Arrange
      const locaisMock = [
        {
          id_local: 1,
          id_usuario: 5,
          nu_cep: '12345678',
          nu_casa: '100',
        },
        {
          id_local: 2,
          id_usuario: 6,
          nu_cep: '87654321',
          nu_casa: '200',
        },
      ];

      mockConexao.query.mockResolvedValueOnce({
        rows: locaisMock,
      });

      // Act
      await localService.getLocais();

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith('SELECT * FROM tb_local_dn');
      expect(mockDatabase.setDados).toHaveBeenCalledWith(2, locaisMock);
    });

    it('deve retornar vazio quando não há locais', async () => {
      // Arrange
      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await localService.getLocais();

      // Assert
      expect(mockDatabase.setDados).toHaveBeenCalledWith(0, []);
    });
  });

  describe('getMeusLocais', () => {
    it('deve buscar locais de um usuário específico', async () => {
      // Arrange
      const locaisUsuarioMock = [
        {
          id_local: 3,
          id_usuario: 5,
          nu_cep: '11111111',
          nu_casa: '300',
        },
        {
          id_local: 1,
          id_usuario: 5,
          nu_cep: '22222222',
          nu_casa: '100',
        },
      ];

      mockConexao.query.mockResolvedValueOnce({
        rows: locaisUsuarioMock,
      });

      // Act
      await localService.getMeusLocais(5);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith(
        'SELECT * FROM tb_local_dn WHERE id_usuario = $1 ORDER BY id_local DESC',
        [5]
      );
      expect(mockDatabase.setDados).toHaveBeenCalledWith(2, locaisUsuarioMock);
    });

    it('deve retornar vazio quando usuário não tem locais', async () => {
      // Arrange
      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await localService.getMeusLocais(999);

      // Assert
      expect(mockDatabase.setDados).toHaveBeenCalledWith(0, []);
    });
  });

  describe('createLocal', () => {
    it('deve criar um local com sucesso', async () => {
      // Arrange
      const novoLocal = {
        nu_cep: '12345678',
        nu_casa: '100',
        id_usuario: 5,
        nu_cnpj: null,
        dc_complemento: 'Apto 101',
      };

      mockConexao.query
        .mockResolvedValueOnce({ rows: [{ id_sequence: 50 }] }) // SELECT sequence
        .mockResolvedValueOnce({ rows: [] }) // INSERT sequence
        .mockResolvedValueOnce({ rows: [] }); // INSERT local

      // Act
      await localService.createLocal(novoLocal);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledTimes(3);
      expect(mockConexao.query).toHaveBeenNthCalledWith(
        1,
        'SELECT id_sequence FROM tb_sequence_dn ORDER BY id_sequence DESC LIMIT 1'
      );
      expect(mockConexao.query).toHaveBeenNthCalledWith(
        2,
        'INSERT INTO tb_sequence_dn (id_sequence, nm_sequence) VALUES ($1, $2)',
        [51, 'L']
      );
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Local criado com sucesso' })
      );
    });

    it('deve criar local com campos opcionais nulos', async () => {
      // Arrange
      const novoLocal = {
        nu_cep: '12345678',
        nu_casa: '100',
        id_usuario: 5,
      };

      mockConexao.query
        .mockResolvedValueOnce({ rows: [{ id_sequence: 50 }] })
        .mockResolvedValueOnce({ rows: [] })
        .mockResolvedValueOnce({ rows: [] });

      // Act
      await localService.createLocal(novoLocal);

      // Assert
      const insertCall = mockConexao.query.mock.calls[2];
      expect(insertCall[1][4]).toBeNull(); // nu_cnpj
      expect(insertCall[1][5]).toBeNull(); // dc_complemento
    });
  });

  describe('deleteLocal', () => {
    it('deve deletar um local e suas dependências', async () => {
      // Arrange
      mockConexao.query
        .mockResolvedValueOnce({ rows: [] }) // DELETE encontros
        .mockResolvedValueOnce({ rows: [] }) // DELETE cardapios
        .mockResolvedValueOnce({ rows: [] }); // DELETE local

      // Act
      await localService.deleteLocal(1);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledTimes(3);
      expect(mockConexao.query).toHaveBeenNthCalledWith(
        1,
        'DELETE FROM tb_encontro_dn WHERE id_local = $1',
        [1]
      );
      expect(mockConexao.query).toHaveBeenNthCalledWith(
        2,
        'DELETE FROM tb_cardapio_dn WHERE id_local = $1',
        [1]
      );
      expect(mockConexao.query).toHaveBeenNthCalledWith(
        3,
        'DELETE FROM tb_local_dn WHERE id_local = $1',
        [1]
      );
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Deletado com sucesso' })
      );
    });
  });
});

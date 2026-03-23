import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import { ImagemService } from '../../src/modules/imagem/imagem.service';
import { Database } from '../../src/database/Database';

describe('ImagemService - Integration Tests', () => {
  let imagemService: ImagemService;
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

    imagemService = new ImagemService(mockDatabase);
  });

  describe('getImagem', () => {
    it('deve buscar uma imagem por ID', async () => {
      // Arrange
      const imagemMock = {
        id_imagem: 1,
        vl_url: 'https://exemplo.com/imagem.jpg',
        id_sequence: 100,
        nm_sequence: 'I',
      };

      mockConexao.query.mockResolvedValueOnce({
        rows: [imagemMock],
      });

      // Act
      await imagemService.getImagem(100);

      // Assert
      expect(mockConexao.query).toHaveBeenCalled();
      expect(mockConexao.query.mock.calls[0][1]).toEqual([100]);
      expect(mockDatabase.setDados).toHaveBeenCalledWith(1, [imagemMock]);
    });

    it('deve retornar vazio quando imagem não existe', async () => {
      // Arrange
      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await imagemService.getImagem(999);

      // Assert
      expect(mockDatabase.setDados).toHaveBeenCalledWith(0, []);
    });
  });

  describe('createImagem', () => {
    it('deve criar uma imagem com sucesso', async () => {
      // Arrange
      const id_sequence = 100;
      const vl_url = 'https://exemplo.com/imagem.jpg';

      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await imagemService.createImagem(id_sequence, vl_url);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith(
        'INSERT INTO tb_imagem_dn (vl_url, id_sequence) VALUES ($1, $2)',
        [vl_url, id_sequence]
      );
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Imagem criada com sucesso!' })
      );
    });

    it('deve criar imagem com URL diferente', async () => {
      // Arrange
      const id_sequence = 200;
      const vl_url = 'https://cdn.exemplo.com/foto.png';

      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await imagemService.createImagem(id_sequence, vl_url);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith(
        'INSERT INTO tb_imagem_dn (vl_url, id_sequence) VALUES ($1, $2)',
        [vl_url, id_sequence]
      );
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Imagem criada com sucesso!' })
      );
    });
  });

  describe('deleteImagem', () => {
    it('deve deletar uma imagem com sucesso', async () => {
      // Arrange
      mockConexao.query.mockResolvedValueOnce({ 
        rows: [],
        rowCount: 1 
      });

      // Act
      await imagemService.deleteImagem(1);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith(
        'DELETE FROM tb_imagem_dn WHERE id_imagem = $1',
        [1]
      );
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Deletado com sucesso' })
      );
    });

    it('deve lançar erro quando imagem não existe', async () => {
      // Arrange
      mockConexao.query.mockResolvedValueOnce({ 
        rows: [],
        rowCount: 0 
      });

      // Act & Assert
      await expect(imagemService.deleteImagem(999)).rejects.toThrow(
        'Não foi possível deletar a imagem'
      );
    });
  });
});

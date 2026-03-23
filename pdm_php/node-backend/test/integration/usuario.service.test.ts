import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import { UsuarioService } from '../../src/modules/usuario/usuario.service';
import { Database } from '../../src/database/Database';
import { encrypt } from '../../src/utils/encryption';

describe('UsuarioService - Integration Tests', () => {
  let usuarioService: UsuarioService;
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

    usuarioService = new UsuarioService(mockDatabase);
  });

  describe('createUsuario', () => {
    it('deve criar um usuário com sucesso', async () => {
      // Arrange
      const novoUsuario = {
        nu_cpf: '12345678900',
        nm_usuario: 'João',
        nm_sobrenome: 'Silva',
        vl_email: 'joao@email.com',
        vl_senha: 'senha123',
        fl_anfitriao: false,
      };

      const usuarioCriado = {
        id_usuario: 101,
        nu_cpf: '12345678900',
        nm_usuario: 'João',
        nm_sobrenome: 'Silva',
        vl_email: 'joao@email.com',
      };

      mockConexao.query
        .mockResolvedValueOnce({ rows: [{ total: '0' }] }) // CHECK CPF/Email
        .mockResolvedValueOnce({ rows: [{ id_sequence: 100 }] }) // SELECT sequence
        .mockResolvedValueOnce({ rows: [] }) // INSERT sequence
        .mockResolvedValueOnce({ rows: [] }) // INSERT usuario
        .mockResolvedValueOnce({ rows: [usuarioCriado] }); // SELECT usuario criado

      // Act
      await usuarioService.createUsuario(novoUsuario);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledTimes(5);
      expect(mockDatabase.setDados).toHaveBeenCalledWith(1, [usuarioCriado]);
    });

    it('deve criptografar a senha ao criar usuário', async () => {
      // Arrange
      const novoUsuario = {
        nu_cpf: '12345678900',
        nm_usuario: 'João',
        nm_sobrenome: 'Silva',
        vl_email: 'joao@email.com',
        vl_senha: 'senha123',
      };

      mockConexao.query
        .mockResolvedValueOnce({ rows: [{ total: '0' }] })
        .mockResolvedValueOnce({ rows: [{ id_sequence: 100 }] })
        .mockResolvedValueOnce({ rows: [] })
        .mockResolvedValueOnce({ rows: [] })
        .mockResolvedValueOnce({ rows: [{ id_usuario: 101 }] });

      // Act
      await usuarioService.createUsuario(novoUsuario);

      // Assert
      const insertCall = mockConexao.query.mock.calls[3];
      const senhaCriptografada = insertCall[1][5]; // 6º parâmetro (vl_senha)
      
      expect(senhaCriptografada).not.toBe('senha123');
      expect(senhaCriptografada).toBeTruthy();
      expect(typeof senhaCriptografada).toBe('string');
    });
  });

  describe('getUsuario', () => {
    it('deve buscar um usuário por ID', async () => {
      // Arrange
      const usuarioMock = {
        id_usuario: 1,
        nu_cpf: '12345678900',
        nm_usuario: 'João',
        nm_sobrenome: 'Silva',
        vl_email: 'joao@email.com',
        fl_anfitriao: false,
      };

      mockConexao.query.mockResolvedValueOnce({
        rows: [usuarioMock],
      });

      // Act
      await usuarioService.getUsuario(1);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith(
        'SELECT * FROM tb_usuario_dn WHERE id_usuario = $1',
        [1]
      );
      expect(mockDatabase.setDados).toHaveBeenCalledWith(1, [usuarioMock]);
    });

    it('deve lançar erro quando usuário não existe', async () => {
      // Arrange
      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act & Assert
      await expect(usuarioService.getUsuario(999)).rejects.toThrow('Usuario nao Localizado');
    });
  });

  describe('loginUsuario', () => {
    it('deve fazer login com credenciais válidas', async () => {
      // Arrange
      const senhaOriginal = 'senha123';
      const senhaCriptografada = encrypt(senhaOriginal);
      
      const usuarioMock = {
        id_usuario: 1,
        nu_cpf: '12345678900',
        nm_usuario: 'João',
        nm_sobrenome: 'Silva',
        vl_email: 'joao@email.com',
        vl_senha: senhaCriptografada,
        fl_anfitriao: false,
        vl_foto: null,
      };

      mockConexao.query.mockResolvedValueOnce({
        rows: [usuarioMock],
      });

      // Act
      await usuarioService.loginUsuario({
        vl_email: 'joao@email.com',
        vl_senha: senhaOriginal,
      });

      // Assert
      expect(mockConexao.query).toHaveBeenCalled();
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({
          id_usuario: 1,
          nm_usuario: 'João',
          nm_sobrenome: 'Silva',
          vl_email: 'joao@email.com',
        })
      );
    });

    it('deve falhar login com senha incorreta', async () => {
      // Arrange
      const senhaCriptografada = encrypt('senha123');
      
      const usuarioMock = {
        id_usuario: 1,
        vl_email: 'joao@email.com',
        vl_senha: senhaCriptografada,
      };

      mockConexao.query.mockResolvedValueOnce({
        rows: [usuarioMock],
      });

      // Act & Assert
      await expect(
        usuarioService.loginUsuario({
          vl_email: 'joao@email.com',
          vl_senha: 'senhaErrada',
        })
      ).rejects.toThrow('Email ou senha inválidos');
    });

    it('deve falhar login com email inexistente', async () => {
      // Arrange
      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act & Assert
      await expect(
        usuarioService.loginUsuario({
          vl_email: 'inexistente@email.com',
          vl_senha: 'senha123',
        })
      ).rejects.toThrow('Email ou senha inválidos');
    });
  });

  describe('deleteUsuario', () => {
    it('deve deletar um usuário', async () => {
      // Arrange
      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await usuarioService.deleteUsuario(1);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith(
        'DELETE FROM tb_usuario_dn WHERE id_usuario = $1',
        [1]
      );
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Deletado com sucesso' })
      );
    });
  });

  describe('atualizarFotoPerfil', () => {
    it('deve atualizar foto de perfil', async () => {
      // Arrange
      const novaFoto = 'https://exemplo.com/foto.jpg';
      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await usuarioService.atualizarFotoPerfil(1, novaFoto);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith(
        'UPDATE tb_usuario_dn SET vl_foto = $1 WHERE id_usuario = $2',
        [novaFoto, 1]
      );
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Foto atualizada com sucesso' })
      );
    });
  });

});

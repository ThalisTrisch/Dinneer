import { describe, it, expect, beforeEach, jest } from '@jest/globals';
import { EncontroService } from '../../src/modules/encontro/encontro.service';
import { Database } from '../../src/database/Database';

describe('EncontroService - Integration Tests', () => {
  let encontroService: EncontroService;
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

    encontroService = new EncontroService(mockDatabase);
  });

  describe('addUsuarioEncontro', () => {
    it('deve adicionar usuário ao encontro com sucesso', async () => {
      // Arrange
      const id_usuario = 5;
      const id_encontro = 10;
      const nu_dependentes = 2;

      mockConexao.query
        .mockResolvedValueOnce({ rows: [] }) // CHECK se já solicitou
        .mockResolvedValueOnce({ rows: [] }); // INSERT solicitação

      // Act
      await encontroService.addUsuarioEncontro(id_usuario, id_encontro, nu_dependentes);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledTimes(2);
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Solicitação enviada! Aguarde a aprovação do anfitrião.' })
      );
    });

    it('deve lançar erro quando usuário já solicitou reserva', async () => {
      // Arrange
      const id_usuario = 5;
      const id_encontro = 10;
      const nu_dependentes = 1;

      mockConexao.query.mockResolvedValueOnce({
        rows: [{ id_usuario: 5, id_encontro: 10 }],
      });

      // Act & Assert
      await expect(
        encontroService.addUsuarioEncontro(id_usuario, id_encontro, nu_dependentes)
      ).rejects.toThrow('Você já solicitou reserva para este jantar.');
    });
  });

  describe('aprovarReserva', () => {
    it('deve aprovar reserva quando há vagas disponíveis', async () => {
      // Arrange
      const id_encontro = 10;
      const id_usuario_convidado = 5;

      mockConexao.query
        .mockResolvedValueOnce({
          rows: [{ nu_max_convidados: '10', total_confirmados: '5' }],
        }) // Capacidade
        .mockResolvedValueOnce({
          rows: [{ nu_dependentes: 1 }],
        }) // Dependentes do convidado
        .mockResolvedValueOnce({ rows: [] }); // UPDATE status

      // Act
      await encontroService.aprovarReserva(id_encontro, id_usuario_convidado);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledTimes(3);
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Convidado confirmado com sucesso!' })
      );
    });

    it('deve lançar erro quando não há vagas suficientes', async () => {
      // Arrange
      const id_encontro = 10;
      const id_usuario_convidado = 5;

      mockConexao.query
        .mockResolvedValueOnce({
          rows: [{ nu_max_convidados: '10', total_confirmados: '9' }],
        })
        .mockResolvedValueOnce({
          rows: [{ nu_dependentes: 2 }], // Precisa de 3 lugares (1 + 2)
        });

      // Act & Assert
      await expect(
        encontroService.aprovarReserva(id_encontro, id_usuario_convidado)
      ).rejects.toThrow('Não há vagas suficientes para aprovar este grupo.');
    });

    it('deve aprovar quando convidado não tem dependentes', async () => {
      // Arrange
      const id_encontro = 10;
      const id_usuario_convidado = 5;

      mockConexao.query
        .mockResolvedValueOnce({
          rows: [{ nu_max_convidados: '10', total_confirmados: '9' }],
        })
        .mockResolvedValueOnce({
          rows: [{ nu_dependentes: 0 }],
        })
        .mockResolvedValueOnce({ rows: [] });

      // Act
      await encontroService.aprovarReserva(id_encontro, id_usuario_convidado);

      // Assert
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Convidado confirmado com sucesso!' })
      );
    });
  });

  describe('rejeitarReserva', () => {
    it('deve rejeitar reserva com sucesso', async () => {
      // Arrange
      const id_encontro = 10;
      const id_usuario_convidado = 5;

      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await encontroService.rejeitarReserva(id_encontro, id_usuario_convidado);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith(
        'DELETE FROM tb_encontro_usuario_dn WHERE id_encontro = $1 AND id_usuario = $2',
        [id_encontro, id_usuario_convidado]
      );
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Solicitação recusada.' })
      );
    });
  });

  describe('getParticipantes', () => {
    it('deve listar participantes do encontro', async () => {
      // Arrange
      const id_encontro = 10;
      const participantesMock = [
        {
          id_usuario: 5,
          nome_completo: 'João Silva',
          vl_foto: null,
          nu_dependentes: 2,
          fl_status: 'C',
        },
        {
          id_usuario: 6,
          nome_completo: 'Maria Santos',
          vl_foto: null,
          nu_dependentes: 0,
          fl_status: 'P',
        },
      ];

      mockConexao.query.mockResolvedValueOnce({
        rows: participantesMock,
      });

      // Act
      await encontroService.getParticipantes(id_encontro);

      // Assert
      expect(mockConexao.query).toHaveBeenCalled();
      expect(mockDatabase.setDados).toHaveBeenCalledWith(2, participantesMock);
    });

    it('deve retornar vazio quando não há participantes', async () => {
      // Arrange
      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await encontroService.getParticipantes(10);

      // Assert
      expect(mockDatabase.setDados).toHaveBeenCalledWith(0, []);
    });
  });

  describe('verificarReserva', () => {
    it('deve retornar true quando usuário já tem reserva', async () => {
      // Arrange
      const id_usuario = 5;
      const id_encontro = 10;

      mockConexao.query.mockResolvedValueOnce({
        rows: [{ fl_status: 'C' }],
      });

      // Act
      await encontroService.verificarReserva(id_usuario, id_encontro);

      // Assert
      expect(mockDatabase.setDados).toHaveBeenCalledWith(1, {
        ja_reservou: true,
        status: 'C',
      });
    });

    it('deve retornar false quando usuário não tem reserva', async () => {
      // Arrange
      const id_usuario = 5;
      const id_encontro = 10;

      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await encontroService.verificarReserva(id_usuario, id_encontro);

      // Assert
      expect(mockDatabase.setDados).toHaveBeenCalledWith(0, {
        ja_reservou: false,
        status: null,
      });
    });
  });

  describe('deleteUsuarioEncontro', () => {
    it('deve cancelar participação do usuário', async () => {
      // Arrange
      const id_usuario = 5;
      const id_encontro = 10;

      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await encontroService.deleteUsuarioEncontro(id_usuario, id_encontro);

      // Assert
      expect(mockConexao.query).toHaveBeenCalledWith(
        'DELETE FROM tb_encontro_usuario_dn WHERE id_usuario = $1 AND id_encontro = $2',
        [id_usuario, id_encontro]
      );
      expect(mockDatabase.setDados).toHaveBeenCalledWith(
        1,
        expect.objectContaining({ Mensagem: 'Reserva cancelada.' })
      );
    });
  });

  describe('getMinhasReservas', () => {
    it('deve listar reservas do usuário como convidado', async () => {
      // Arrange
      const id_usuario = 5;
      const reservasMock = [
        {
          id_cardapio: 1,
          nm_cardapio: 'Jantar Italiano',
          id_encontro: 10,
          hr_encontro: '2026-12-31 19:00:00',
          fl_status: 'C',
          nu_convidados_confirmados: 5,
        },
      ];

      mockConexao.query.mockResolvedValueOnce({
        rows: reservasMock,
      });

      // Act
      await encontroService.getMinhasReservas(id_usuario);

      // Assert
      expect(mockConexao.query).toHaveBeenCalled();
      expect(mockDatabase.setDados).toHaveBeenCalledWith(1, reservasMock);
    });

    it('deve retornar vazio quando usuário não tem reservas', async () => {
      // Arrange
      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await encontroService.getMinhasReservas(5);

      // Assert
      expect(mockDatabase.setDados).toHaveBeenCalledWith(0, []);
    });
  });

  describe('getMeusJantaresCriados', () => {
    it('deve listar jantares criados pelo usuário como anfitrião', async () => {
      // Arrange
      const id_usuario = 5;
      const jantaresMock = [
        {
          id_cardapio: 1,
          nm_cardapio: 'Jantar Italiano',
          id_encontro: 10,
          hr_encontro: '2026-12-31 19:00:00',
          nu_convidados_confirmados: 5,
          nu_solicitacoes_pendentes: 2,
        },
      ];

      mockConexao.query.mockResolvedValueOnce({
        rows: jantaresMock,
      });

      // Act
      await encontroService.getMeusJantaresCriados(id_usuario);

      // Assert
      expect(mockConexao.query).toHaveBeenCalled();
      expect(mockDatabase.setDados).toHaveBeenCalledWith(1, jantaresMock);
    });

    it('deve retornar vazio quando usuário não criou jantares', async () => {
      // Arrange
      mockConexao.query.mockResolvedValueOnce({ rows: [] });

      // Act
      await encontroService.getMeusJantaresCriados(5);

      // Assert
      expect(mockDatabase.setDados).toHaveBeenCalledWith(0, []);
    });
  });
});

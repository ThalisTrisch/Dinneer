import 'package:flutter_test/flutter_test.dart';
import 'package:dinneer/service/refeicao/Cardapio.dart';

/// Map base imitando o payload da API, onde os números costumam vir como String.
Map<String, dynamic> _mapBase() => {
  'id_usuario': '7',
  'nm_usuario_anfitriao': 'Maria',
  'nm_cardapio': 'Feijoada',
  'ds_cardapio': 'Completa',
  'id_cardapio': '12',
  'id_encontro': '34',
  'hr_encontro': '2030-05-20T19:30:00.000',
  'nu_max_convidados': '8',
  'nu_convidados_confirmados': '3',
  'preco_refeicao': '49.90',
  'id_local': '5',
  'nu_cep': '01001000',
  'nu_casa': '100',
  'vl_foto_cardapio': 'http://img/prato.jpg',
  'vl_foto': 'http://img/maria.jpg',
  'nu_solicitacoes_pendentes': '2',
  'fl_status': 'C',
};

void main() {
  group('Cardapio.fromMap', () {
    test('converte campos numéricos vindos como String', () {
      final cardapio = Cardapio.fromMap(_mapBase());

      expect(cardapio.idUsuario, 7);
      expect(cardapio.idRefeicao, 12);
      expect(cardapio.idEncontro, 34);
      expect(cardapio.nuMaxConvidados, 8);
      expect(cardapio.nuConvidadosConfirmados, 3);
      expect(cardapio.precoRefeicao, 49.90);
      expect(cardapio.idLocal, 5);
      expect(cardapio.nuSolicitacoesPendentes, 2);
    });

    test('aceita campos numéricos já como int/double', () {
      final map = _mapBase()
        ..['id_usuario'] = 7
        ..['nu_max_convidados'] = 8
        ..['preco_refeicao'] = 49.90;

      final cardapio = Cardapio.fromMap(map);

      expect(cardapio.idUsuario, 7);
      expect(cardapio.nuMaxConvidados, 8);
      expect(cardapio.precoRefeicao, 49.90);
    });

    test('preserva strings de texto e endereço', () {
      final cardapio = Cardapio.fromMap(_mapBase());

      expect(cardapio.nmUsuarioAnfitriao, 'Maria');
      expect(cardapio.nmCardapio, 'Feijoada');
      expect(cardapio.dsCardapio, 'Completa');
      expect(cardapio.nuCep, '01001000');
      expect(cardapio.nuCasa, '100');
      expect(cardapio.urlFoto, 'http://img/prato.jpg');
      expect(cardapio.statusReserva, 'C');
    });

    test('idEncontro cai para id_cardapio quando ausente', () {
      final map = _mapBase()..remove('id_encontro');

      final cardapio = Cardapio.fromMap(map);

      expect(cardapio.idEncontro, 12); // mesmo valor de id_cardapio
    });

    test('urlFotoAnfitriao usa vl_foto e cai para vl_foto_usuario', () {
      final comVlFoto = Cardapio.fromMap(_mapBase());
      expect(comVlFoto.urlFotoAnfitriao, 'http://img/maria.jpg');

      final map = _mapBase()
        ..remove('vl_foto')
        ..['vl_foto_usuario'] = 'http://img/fallback.jpg';
      final comFallback = Cardapio.fromMap(map);
      expect(comFallback.urlFotoAnfitriao, 'http://img/fallback.jpg');
    });

    test('aplica defaults para campos ausentes ou inválidos', () {
      final map = _mapBase()
        ..remove('ds_cardapio')
        ..remove('nu_solicitacoes_pendentes')
        ..['preco_refeicao'] = 'abc' // inválido -> 0.0
        ..['nu_max_convidados'] = ''; // inválido -> 0

      final cardapio = Cardapio.fromMap(map);

      expect(cardapio.dsCardapio, '');
      expect(cardapio.nuSolicitacoesPendentes, 0);
      expect(cardapio.precoRefeicao, 0.0);
      expect(cardapio.nuMaxConvidados, 0);
    });

    test('parseia hr_encontro em ISO 8601', () {
      final cardapio = Cardapio.fromMap(_mapBase());

      expect(cardapio.hrEncontro.year, 2030);
      expect(cardapio.hrEncontro.month, 5);
      expect(cardapio.hrEncontro.day, 20);
      expect(cardapio.hrEncontro.hour, 19);
    });
  });

  group('Cardapio - getters de formatação', () {
    // Ambos os getters têm try/catch com fallback, então nunca lançam.
    test('precoFormatado e dataFormatada retornam texto', () {
      final cardapio = Cardapio.fromMap(_mapBase());

      expect(cardapio.precoFormatado, isNotEmpty);
      expect(cardapio.dataFormatada, isNotEmpty);
    });
  });
}

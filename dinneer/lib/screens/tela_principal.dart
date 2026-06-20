import 'package:flutter/material.dart';
import '../widgets/barra_de_navegacao.dart';
import 'tela_home.dart';
import 'perfil/tela_perfil.dart';
import 'tela_reservas.dart';
import 'tela_lista_chats.dart';

class TelaPrincipal extends StatefulWidget {
  final Map<String, dynamic> dadosUsuario;

  const TelaPrincipal({super.key, required this.dadosUsuario});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _paginaAtual = 0;
  late List<Widget> _paginas;

  @override
  void initState() {
    super.initState();

    int idUsuario = 0;
    if (widget.dadosUsuario['id_usuario'] != null) {
      idUsuario =
          int.tryParse(widget.dadosUsuario['id_usuario'].toString()) ?? 0;
    }

    _paginas = [
      TelaHome(idUsuarioLogado: idUsuario),
      const TelaReservas(),
      const TelaListaChats(),
      TelaPerfil(dadosUsuario: widget.dadosUsuario),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _paginaAtual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _paginas.length > _paginaAtual
          ? _paginas[_paginaAtual]
          : _paginas[0],
      bottomNavigationBar: BarraNavegacaoCustomizada(
        index: _paginaAtual,
        onTap: _onItemTapped,
      ),
    );
  }
}

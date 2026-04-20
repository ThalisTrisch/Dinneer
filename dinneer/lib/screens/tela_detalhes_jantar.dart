import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:dinneer/service/encontro/EncontroService.dart';
import 'package:dinneer/service/sessao/SessionService.dart';
import 'package:dinneer/service/refeicao/cardapioService.dart';
import 'package:dinneer/screens/tela_editar_jantar.dart';
import 'package:dinneer/widgets/modal_avaliacao.dart';

class TelaDetalhesJantar extends StatefulWidget {
  final Cardapio refeicao;

  const TelaDetalhesJantar({super.key, required this.refeicao});

  @override
  State<TelaDetalhesJantar> createState() => _TelaDetalhesJantarState();
}

class _TelaDetalhesJantarState extends State<TelaDetalhesJantar> {
  late Future<LatLng?> _coordenadasFuture;
  int? _idUsuarioLogado;
  bool _carregandoUsuario = true;
  bool _jaReservei = false;
  String? _statusReserva;
  String _enderecoLegivel = "";

  @override
  void initState() {
    super.initState();
    _enderecoLegivel = "CEP: ${widget.refeicao.nuCep}, Nº ${widget.refeicao.nuCasa}";
    _coordenadasFuture = _buscarCoordenadasPrecisa();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    final idStr = await SessionService.pegarUsuarioId();
    if (mounted) {
      setState(() {
        _idUsuarioLogado = idStr != null ? int.tryParse(idStr) : null;
      });
      
      if (_idUsuarioLogado != null) {
        final dadosReserva = await EncontroService.verificarSeJaReservei(
          _idUsuarioLogado!, 
          widget.refeicao.idEncontro
        );
        
        bool reservou = false;
        String? status;
        
        if (dadosReserva is Map) {
             reservou = dadosReserva['ja_reservou'] ?? false;
             status = dadosReserva['status'];
        } else if (dadosReserva is bool) {
             reservou = dadosReserva;
        }

        if (mounted) {
          setState(() {
            _jaReservei = reservou;
            _statusReserva = status;
            _carregandoUsuario = false;
          });
        }
      } else {
        if (mounted) setState(() => _carregandoUsuario = false);
      }
    }
  }

  Future<LatLng?> _buscarCoordenadasPrecisa() async {
    try {
      String cepLimpo = widget.refeicao.nuCep.replaceAll(RegExp(r'[^0-9]'), '');
      final urlViaCep = Uri.parse("https://viacep.com.br/ws/$cepLimpo/json/");
      final responseCep = await http.get(urlViaCep);

      String queryBusca;

      if (responseCep.statusCode == 200) {
        final dadosCep = jsonDecode(responseCep.body);
        if (dadosCep['erro'] != true) {
          String logradouro = dadosCep['logradouro'];
          String bairro = dadosCep['bairro'];
          String localidade = dadosCep['localidade'];
          String uf = dadosCep['uf'];
          String numero = widget.refeicao.nuCasa;
          
          if (mounted) {
            setState(() {
              _enderecoLegivel = "$logradouro, $numero\n$bairro - $localidade/$uf";
            });
          }

          queryBusca = "$logradouro, $numero, $localidade - $uf, Brasil";
        } else {
          queryBusca = "${widget.refeicao.nuCep}, ${widget.refeicao.nuCasa}, Brasil";
        }
      } else {
        queryBusca = "${widget.refeicao.nuCep}, ${widget.refeicao.nuCasa}, Brasil";
      }

      final queryEncoded = Uri.encodeComponent(queryBusca);
      final urlNominatim = Uri.parse("https://nominatim.openstreetmap.org/search?q=$queryEncoded&format=json&limit=1");

      final responseMap = await http.get(urlNominatim, headers: {'User-Agent': 'com.example.dinneer'});

      if (responseMap.statusCode == 200) {
        final dadosMap = jsonDecode(responseMap.body);
        if (dadosMap is List && dadosMap.isNotEmpty) {
          final lat = double.parse(dadosMap[0]['lat']);
          final lon = double.parse(dadosMap[0]['lon']);
          return LatLng(lat, lon);
        }
      }
    } catch (e) {
      debugPrint("Erro: $e");
    }
    return null;
  }

  Future<void> _realizarReserva(int dependentes) async {
    try {
      if (_idUsuarioLogado == null) throw Exception("Erro de sessão.");

      final resposta = await EncontroService.reservar(_idUsuarioLogado!, widget.refeicao.idEncontro, dependentes);
      
      if (resposta != null && resposta['dados'] != null) {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Solicitação enviada com sucesso!"), backgroundColor: Colors.green),
          );
          _carregarDadosIniciais();
          Navigator.pop(context, true); 
        }
      } else {
        String erro = resposta?['Mensagem'] ?? "Erro desconhecido.";
        throw Exception(erro);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Atenção: $e"), backgroundColor: Colors.orange));
      }
    }
  }

  Future<void> _cancelarMinhaReserva() async {
    try {
      await EncontroService.cancelarReserva(_idUsuarioLogado!, widget.refeicao.idEncontro);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reserva cancelada."), backgroundColor: Colors.orange),
        );
        _carregarDadosIniciais();
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao cancelar."), backgroundColor: Colors.red));
    }
  }

  Future<void> _deletarJantar() async {
    try {
      await CardapioService.deleteJantar(widget.refeicao.idRefeicao);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jantar cancelado.")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao excluir."), backgroundColor: Colors.red));
    }
  }

  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancelar Jantar?"),
        content: const Text("Isso removerá o jantar e cancelará todas as reservas. Tem certeza?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Não")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deletarJantar();
            },
            child: const Text("Sim, Cancelar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmarCancelamentoReserva() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancelar Reserva?"),
        content: const Text("Você perderá seu lugar neste jantar."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Voltar")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _cancelarMinhaReserva();
            },
            child: const Text("Confirmar Cancelamento", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _mostrarModalAgendamento(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final TextEditingController dependentesController = TextEditingController();
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Agendamento", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text("Quantas pessoas irão jantar com você?"),
                const SizedBox(height: 8),
                TextField(
                  controller: dependentesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Número de convidados extras (0 se for só você)", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final int dependentes = int.tryParse(dependentesController.text) ?? 0;
                      Navigator.pop(context); 
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enviando solicitação...")));
                      _realizarReserva(dependentes);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("ENVIAR SOLICITAÇÃO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool estaLotado = widget.refeicao.nuConvidadosConfirmados >= widget.refeicao.nuMaxConvidados;
    final bool souOAnfitriao = _idUsuarioLogado != null && _idUsuarioLogado == widget.refeicao.idUsuario;

    return Scaffold(
      backgroundColor: Colors.white,
      
      bottomNavigationBar: _carregandoUsuario 
        ? const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()))
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: souOAnfitriao 
              ? _buildBotoesAnfitriao() 
              : _buildBotaoConvidado(estaLotado),
          ),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: ClipPath(
                clipper: AppBarClipper(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    image: (widget.refeicao.urlFoto != null && widget.refeicao.urlFoto!.isNotEmpty)
                        ? DecorationImage(image: NetworkImage(widget.refeicao.urlFoto!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: (widget.refeicao.urlFoto == null || widget.refeicao.urlFoto!.isEmpty)
                      ? const Icon(Icons.restaurant, size: 100, color: Colors.white)
                      : null,
                ),
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.refeicao.nmCardapio, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.refeicao.precoFormatado, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 16),
                  _buildInfoUsuario(),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text("Sobre o Jantar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(widget.refeicao.dsCardapio.isNotEmpty ? widget.refeicao.dsCardapio : "Sem descrição.", style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5)),
                  const SizedBox(height: 24),
                  _buildDetalhesAdicionais(),
                  const SizedBox(height: 24),
                  const Text("Localização", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.red, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _enderecoLegivel, 
                          style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMapa(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotoesAnfitriao() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final atualizou = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TelaEditarJantar(jantar: widget.refeicao)),
              );
              if (atualizou == true && mounted) Navigator.pop(context, true);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Colors.black),
            ),
            child: const Text("EDITAR", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _confirmarExclusao,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("CANCELAR", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoConvidado(bool estaLotado) {
    final bool jantarJaPassou = widget.refeicao.hrEncontro.isBefore(DateTime.now());

    if (_jaReservei) {
      if (jantarJaPassou) {
        return ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true, 
              builder: (_) => ModalAvaliacao(
                idUsuario: _idUsuarioLogado!,
                idEncontro: widget.refeicao.idEncontro,
                onAvaliacaoConcluida: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Obrigado pela avaliação!")));
                },
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber, 
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("AVALIAR EXPERIÊNCIA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        );
      }

      if (_statusReserva == 'P') {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: const [
              Icon(Icons.access_time, color: Colors.orange, size: 30),
              SizedBox(height: 8),
              Text("Solicitação Pendente", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              Text("Aguarde o anfitrião aceitar.", style: TextStyle(fontSize: 12)),
            ],
          ),
        );
      }

      return ElevatedButton(
        onPressed: _confirmarCancelamentoReserva,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.red)),
          elevation: 0,
        ),
        child: const Text("CANCELAR RESERVA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );
    }

    if (jantarJaPassou) {
       return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("JANTAR ENCERRADO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );
    }

    return ElevatedButton(
      onPressed: estaLotado ? null : () => _mostrarModalAgendamento(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: estaLotado ? Colors.grey : Colors.black, 
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Text(
        estaLotado ? 'JANTAR LOTADO' : 'SOLICITAR RESERVA', 
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
      ),
    );
  }

  Widget _buildMapa() {
    return FutureBuilder<LatLng?>(
      future: _coordenadasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(height: 250, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)), child: const Center(child: CircularProgressIndicator(color: Colors.black)));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Container(height: 250, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.location_off, color: Colors.grey, size: 40), const SizedBox(height: 8), Text("Endereço não localizado: ${widget.refeicao.nuCep}", style: const TextStyle(color: Colors.grey))]));
        }
        final coordenadas = snapshot.data!;
        return Container(
          height: 250,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              options: MapOptions(initialCenter: coordenadas, initialZoom: 16.0, interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate)),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.dinneer'),
                MarkerLayer(markers: [Marker(point: coordenadas, width: 80, height: 80, child: const Icon(Icons.location_on, color: Colors.red, size: 40))]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoUsuario() {
    return Row(
      children: [
        CircleAvatar(radius: 26, backgroundColor: Colors.grey[300], backgroundImage: (widget.refeicao.urlFotoAnfitriao != null && widget.refeicao.urlFotoAnfitriao!.isNotEmpty) ? NetworkImage(widget.refeicao.urlFotoAnfitriao!) : null, child: (widget.refeicao.urlFotoAnfitriao == null || widget.refeicao.urlFotoAnfitriao!.isEmpty) ? const Icon(Icons.person, color: Colors.white) : null),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Anfitrião", style: TextStyle(fontSize: 12, color: Colors.grey[600])), Text(widget.refeicao.nmUsuarioAnfitriao, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Row(children: [Icon(Icons.star, color: Colors.amber, size: 16), Icon(Icons.star, color: Colors.amber, size: 16), Icon(Icons.star, color: Colors.amber, size: 16), Icon(Icons.star, color: Colors.amber, size: 16), Icon(Icons.star, color: Colors.amber, size: 16)])]),
      ],
    );
  }

  Widget _buildDetalhesAdicionais() {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildInfoRow(Icons.calendar_today, widget.refeicao.dataFormatada), Container(width: 1, height: 24, color: Colors.grey[300]), _buildInfoRow(Icons.people_alt_outlined, '${widget.refeicao.nuConvidadosConfirmados}/${widget.refeicao.nuMaxConvidados} vagas')]));
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(children: [Icon(icon, size: 20, color: Colors.black87), const SizedBox(width: 8), Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500))]);
  }
}

class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const curveHeight = 40.0;
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - curveHeight);
    path.quadraticBezierTo(size.width / 2, size.height, 0, size.height - curveHeight);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

import 'package:dinneer/service/refeicao/Cardapio.dart';
import 'package:flutter/material.dart';
import '../screens/tela_detalhes_jantar.dart';

class CardRefeicao extends StatelessWidget {
  final Cardapio refeicao;
  final VoidCallback? onRecarregar;

  const CardRefeicao({
    super.key, 
    required this.refeicao,
    this.onRecarregar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async { 
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TelaDetalhesJantar(refeicao: refeicao)),
        );

        if (result == true && onRecarregar != null) {
          onRecarregar!();
        }
      },
      child: Card(
        elevation: 0,
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 110,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16.0),
                  image: (refeicao.urlFoto != null && refeicao.urlFoto!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(refeicao.urlFoto!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (refeicao.urlFoto == null || refeicao.urlFoto!.isEmpty)
                    ? const Icon(Icons.dinner_dining_outlined, color: Colors.white, size: 50)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 130,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        refeicao.nmCardapio,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      _buildInfoRow(Icons.calendar_today_rounded, refeicao.dataFormatada),
                      Text('${refeicao.precoFormatado} por pessoa', style: const TextStyle(fontWeight: FontWeight.bold)),
                      
                      _buildUserInfo(refeicao),

                      _buildInfoRow(
                        Icons.people_alt_rounded,
                        '${refeicao.nuConvidadosConfirmados}/${refeicao.nuMaxConvidados} vagas'
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
      return Row(children: [Icon(icon, size: 16, color: Colors.grey[700]), const SizedBox(width: 6), Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 12))]);
  }

  Widget _buildUserInfo(Cardapio refeicao) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: Colors.grey[400],
          backgroundImage: (refeicao.urlFotoAnfitriao != null && refeicao.urlFotoAnfitriao!.isNotEmpty)
              ? NetworkImage(refeicao.urlFotoAnfitriao!)
              : null,
          child: (refeicao.urlFotoAnfitriao == null || refeicao.urlFotoAnfitriao!.isEmpty)
              ? const Icon(Icons.person, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Oferecido',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            Text(
              'Por ${refeicao.nmUsuarioAnfitriao}',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500),
            ),
          ],
        )
      ],
    );
  }
}
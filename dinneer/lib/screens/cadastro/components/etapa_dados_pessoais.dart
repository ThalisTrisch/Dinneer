import 'dart:io';
import 'package:flutter/material.dart';

import 'package:dinneer/widgets/campo_de_texto.dart';
import 'package:dinneer/widgets/botao_primario.dart';
import 'link_login.dart';

class EtapaDadosPessoais extends StatelessWidget {
  final TextEditingController nomeController;
  final TextEditingController sobrenomeController;
  final TextEditingController cpfController;
  final File? imagemSelecionada;
  final bool estaCarregando;
  final VoidCallback onEscolherImagem;
  final VoidCallback onCadastrar;

  const EtapaDadosPessoais({
    super.key,
    required this.nomeController,
    required this.sobrenomeController,
    required this.cpfController,
    required this.imagemSelecionada,
    required this.estaCarregando,
    required this.onEscolherImagem,
    required this.onCadastrar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              backgroundImage: imagemSelecionada != null
                  ? FileImage(imagemSelecionada!)
                  : null,
              child: imagemSelecionada == null
                  ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                  : null,
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                onPressed: onEscolherImagem,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        CampoDeTextoCustomizado(controller: nomeController, dica: 'Nome'),
        const SizedBox(height: 16),
        CampoDeTextoCustomizado(
          controller: sobrenomeController,
          dica: 'Sobrenome',
        ),
        const SizedBox(height: 16),
        CampoDeTextoCustomizado(
          controller: cpfController,
          dica: 'CPF (apenas números)',
        ),
        const SizedBox(height: 30),
        BotaoPrimario(
          texto: 'CADASTRAR',
          onPressed: onCadastrar,
          estaCarregando: estaCarregando,
        ),
        const SizedBox(height: 24),
        const LinkLogin(),
      ],
    );
  }
}

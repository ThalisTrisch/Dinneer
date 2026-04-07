import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dinneer/widgets/campo_de_texto.dart';

class EtapaDadosPessoais extends StatelessWidget {
  final TextEditingController nomeController;
  final TextEditingController sobrenomeController;
  final TextEditingController cpfController;
  final File? imagemSelecionada;
  final VoidCallback onEscolherImagem;
  final VoidCallback onCadastrar;
  final VoidCallback onVoltarLogin;
  final bool estaCarregando;

  const EtapaDadosPessoais({
    super.key,
    required this.nomeController,
    required this.sobrenomeController,
    required this.cpfController,
    required this.imagemSelecionada,
    required this.onEscolherImagem,
    required this.onCadastrar,
    required this.onVoltarLogin,
    required this.estaCarregando,
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
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: estaCarregando ? null : onCadastrar,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: estaCarregando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.black),
                  )
                : const Text(
                    'CADASTRAR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Já tem login? ', style: TextStyle(color: Colors.grey)),
            GestureDetector(
              onTap: onVoltarLogin,
              child: const Text(
                'Entre',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

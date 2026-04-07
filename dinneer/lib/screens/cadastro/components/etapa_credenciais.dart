import 'package:flutter/material.dart';
import 'package:dinneer/widgets/campo_de_texto.dart';

class EtapaCredenciais extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final TextEditingController confirmarSenhaController;
  final VoidCallback onProximo;
  final VoidCallback onVoltarLogin;

  const EtapaCredenciais({
    super.key,
    required this.emailController,
    required this.senhaController,
    required this.confirmarSenhaController,
    required this.onProximo,
    required this.onVoltarLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.restaurant_menu, size: 80, color: Colors.black54),
        const SizedBox(height: 20),
        const Text(
          'DINNEER',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 40),
        CampoDeTextoCustomizado(controller: emailController, dica: 'Email'),
        const SizedBox(height: 16),
        CampoDeTextoCustomizado(
          controller: senhaController,
          dica: 'Senha',
          textoObscuro: true,
        ),
        const SizedBox(height: 16),
        CampoDeTextoCustomizado(
          controller: confirmarSenhaController,
          dica: 'Confirmar Senha',
          textoObscuro: true,
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onProximo,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'CONTINUAR',
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

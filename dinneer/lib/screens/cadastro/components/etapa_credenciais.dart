import 'package:flutter/material.dart';

import 'package:dinneer/widgets/campo_de_texto.dart';
import 'package:dinneer/widgets/botao_primario.dart';
import 'link_login.dart';

/// Etapa 1 do cadastro: e-mail, senha e confirmação, com o botão "Continuar".
///
/// Recebe os controllers da tela e delega a validação/avanço para [onContinuar].
class EtapaCredenciais extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final TextEditingController confirmarSenhaController;
  final VoidCallback onContinuar;

  const EtapaCredenciais({
    super.key,
    required this.emailController,
    required this.senhaController,
    required this.confirmarSenhaController,
    required this.onContinuar,
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
        BotaoPrimario(texto: 'CONTINUAR', onPressed: onContinuar),
        const SizedBox(height: 24),
        const LinkLogin(),
      ],
    );
  }
}

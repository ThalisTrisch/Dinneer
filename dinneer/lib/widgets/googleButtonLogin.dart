import 'package:flutter/material.dart';

class GoogleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleLoginButton({
    super.key, 
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black87, // Cor do texto
        backgroundColor: Colors.white,   // Fundo branco clássico do Google
        minimumSize: const Size(double.infinity, 50), // Largura total e altura fixa
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: Colors.grey.shade300), // Borda sutil
        ),
        elevation: 1, // Sombra leve para destacar
      ),
      icon: Image.asset(
        'assets/images/google_logo.png', // Caminho do seu asset
        height: 24.0,
      ),
      label: const Text(
        'Continuar com o Google',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
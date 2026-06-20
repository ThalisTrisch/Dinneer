import 'package:flutter/material.dart';

class CampoMensagem extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onEnviar;
  final VoidCallback onAnexar;

  const CampoMensagem({
    super.key,
    required this.controller,
    required this.onEnviar,
    required this.onAnexar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Digite uma mensagem...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.grey[600],
            child: IconButton(
              icon: const Icon(Icons.attachment, color: Colors.white),
              onPressed: onAnexar,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.grey[800],
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: onEnviar,
            ),
          ),
        ],
      ),
    );
  }
}

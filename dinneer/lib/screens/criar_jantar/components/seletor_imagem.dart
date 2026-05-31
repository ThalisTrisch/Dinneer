import 'dart:io';
import 'package:flutter/material.dart';

/// Área tocável de 200px para escolher a foto do jantar.
///
/// Mostra a imagem local selecionada (se houver), senão uma imagem de rede
/// existente ([urlRede], usada na edição), senão um placeholder. Ao tocar,
/// dispara [onTocar].
class SeletorImagem extends StatelessWidget {
  final File? imagemLocal;
  final String? urlRede;
  final VoidCallback onTocar;

  const SeletorImagem({
    super.key,
    required this.imagemLocal,
    required this.onTocar,
    this.urlRede,
  });

  @override
  Widget build(BuildContext context) {
    final bool temUrlRede = urlRede != null && urlRede!.isNotEmpty;

    DecorationImage? imagem;
    if (imagemLocal != null) {
      imagem = DecorationImage(
        image: FileImage(imagemLocal!),
        fit: BoxFit.cover,
      );
    } else if (temUrlRede) {
      imagem = DecorationImage(
        image: NetworkImage(urlRede!),
        fit: BoxFit.cover,
      );
    }

    final bool semImagem = imagemLocal == null && !temUrlRede;

    return GestureDetector(
      onTap: onTocar,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          image: imagem,
        ),
        child: semImagem
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    "Toque para adicionar foto",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

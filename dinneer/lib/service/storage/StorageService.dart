import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Centraliza a seleção de imagens da galeria e o upload para o Firebase
/// Storage, eliminando a duplicação que existia em criar/editar jantar e perfil.
///
/// Cada chamador controla qualidade, dimensões, pasta de destino, prefixo do
/// arquivo e timeout — mantendo o comportamento específico de cada tela.
class StorageService {
  final ImagePicker _picker = ImagePicker();

  /// Abre a galeria e retorna o arquivo selecionado, ou `null` se o usuário
  /// cancelar. Não captura exceções — o chamador decide como tratá-las.
  Future<File?> escolherImagem({int imageQuality = 80, double? maxWidth}) async {
    final XFile? imagem = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
    );
    if (imagem == null) return null;
    return File(imagem.path);
  }

  /// Faz upload de [imagem] para `Storage/{pasta}/{prefixo}_{timestamp}.jpg`
  /// e retorna a URL de download.
  ///
  /// Se [timeout] for informado, a conclusão do upload é limitada a esse tempo
  /// (lança [TimeoutException] ao estourar). Propaga qualquer erro ao chamador.
  Future<String> uploadImagem(
    File imagem, {
    required String pasta,
    required String prefixo,
    Duration? timeout,
  }) async {
    final String nomeArquivo =
        "${prefixo}_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final Reference ref = FirebaseStorage.instance.ref().child(
      '$pasta/$nomeArquivo',
    );
    final metadata = SettableMetadata(contentType: "image/jpeg");

    final UploadTask task = ref.putFile(imagem, metadata);
    final Future<void> conclusao = task.whenComplete(() {});
    await (timeout != null ? conclusao.timeout(timeout) : conclusao);

    return await ref.getDownloadURL();
  }
}

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> escolherImagem({int imageQuality = 80, double? maxWidth}) async {
    final XFile? imagem = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
    );
    if (imagem == null) return null;
    return File(imagem.path);
  }

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

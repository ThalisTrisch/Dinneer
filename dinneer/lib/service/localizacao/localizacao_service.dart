import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Serviço de localização do usuário.
///
/// Encapsula o geolocator (obter a posição atual, tratando permissões) e o
/// cálculo de distância entre dois pontos via latlong2 (fórmula de Haversine).
class LocalizacaoService {
  /// Distância em quilômetros entre [origem] e [destino].
  ///
  /// Cálculo puro (não depende de GPS), portanto é determinístico e testável.
  double distanciaKm(LatLng origem, LatLng destino) {
    const Distance distancia = Distance();
    final metros = distancia.as(LengthUnit.Meter, origem, destino);
    return metros / 1000;
  }

  /// Retorna a posição atual do usuário como [LatLng], ou `null` quando não
  /// é possível obtê-la (serviço de localização desligado, permissão negada
  /// ou qualquer erro). Nunca lança — o chamador trata o `null` exibindo a
  /// tela normalmente, apenas sem a distância.
  Future<LatLng?> posicaoAtual() async {
    try {
      final bool servicoAtivo = await Geolocator.isLocationServiceEnabled();
      if (!servicoAtivo) return null;

      LocationPermission permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied ||
          permissao == LocationPermission.deniedForever) {
        return null;
      }

      final Position posicao = await Geolocator.getCurrentPosition();
      return LatLng(posicao.latitude, posicao.longitude);
    } catch (e) {
      return null;
    }
  }
}

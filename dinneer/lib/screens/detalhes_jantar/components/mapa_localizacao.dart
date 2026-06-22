import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:dinneer/theme/app_colors.dart';
import 'package:dinneer/theme/app_typography.dart';

class MapaLocalizacao extends StatefulWidget {
  final Future<LatLng?> coordenadasFuture;
  final String nuCep;
  final LatLng? posicaoUsuario;

  const MapaLocalizacao({
    super.key,
    required this.coordenadasFuture,
    required this.nuCep,
    this.posicaoUsuario,
  });

  @override
  State<MapaLocalizacao> createState() => _MapaLocalizacaoState();
}

class _MapaLocalizacaoState extends State<MapaLocalizacao> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(MapaLocalizacao oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Quando a posição do usuário chega (depois do mapa já montado),
    // reenquadra a câmera para mostrar o jantar e o usuário juntos.
    if (widget.posicaoUsuario != null && oldWidget.posicaoUsuario == null) {
      _enquadrarAmbos();
    }
  }

  Future<void> _enquadrarAmbos() async {
    final coordenadasJantar = await widget.coordenadasFuture;
    if (!mounted ||
        coordenadasJantar == null ||
        widget.posicaoUsuario == null) {
      return;
    }
    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds(coordenadasJantar, widget.posicaoUsuario!),
          padding: const EdgeInsets.all(50),
        ),
      );
    } catch (_) {
      // Se o mapa ainda não estiver pronto, mantém o enquadramento inicial.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LatLng?>(
      future: widget.coordenadasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.marfim,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.marfim,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, color: AppColors.bege, size: 40),
                const SizedBox(height: 8),
                Text(
                  "Endereço não localizado: ${widget.nuCep}",
                  style: AppTypography.sans(color: AppColors.bege),
                ),
              ],
            ),
          );
        }
        final coordenadas = snapshot.data!;
        final posicaoUsuario = widget.posicaoUsuario;

        return Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.bordaSuave),
            boxShadow: [
              BoxShadow(
                color: AppColors.tinta.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCameraFit: posicaoUsuario != null
                    ? CameraFit.bounds(
                        bounds: LatLngBounds(coordenadas, posicaoUsuario),
                        padding: const EdgeInsets.all(50),
                      )
                    : null,
                initialCenter: coordenadas,
                initialZoom: 16.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.dinneer',
                ),
                MarkerLayer(
                  markers: [
                    // Marcador do jantar (vermelho)
                    Marker(
                      point: coordenadas,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    // Marcador do usuário (azul), quando disponível
                    if (posicaoUsuario != null)
                      Marker(
                        point: posicaoUsuario,
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

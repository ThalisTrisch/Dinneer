import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:dinneer/theme/app_colors.dart';
import 'package:dinneer/theme/app_typography.dart';

class MapaLocalizacao extends StatelessWidget {
  final Future<LatLng?> coordenadasFuture;
  final String nuCep;

  const MapaLocalizacao({
    super.key,
    required this.coordenadasFuture,
    required this.nuCep,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LatLng?>(
      future: coordenadasFuture,
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
                  "Endereço não localizado: $nuCep",
                  style: AppTypography.sans(color: AppColors.bege),
                ),
              ],
            ),
          );
        }
        final coordenadas = snapshot.data!;
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
              options: MapOptions(
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

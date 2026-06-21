import 'package:flutter/material.dart';
import 'package:dinneer/service/sessao/SessionService.dart';
import 'package:dinneer/screens/tela_login.dart';
import 'package:dinneer/theme/app_colors.dart';

class PerfilHeader extends StatelessWidget {
  final String nomeUsuario;
  final String emailUsuario;
  final String? fotoUrl;
  final bool isUploading;
  final VoidCallback onCameraTap;

  const PerfilHeader({
    super.key,
    required this.nomeUsuario,
    required this.emailUsuario,
    required this.fotoUrl,
    required this.isUploading,
    required this.onCameraTap,
  });

  void _fazerLogout(BuildContext context) async {
    await SessionService.limpar();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const TelaLogin()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      backgroundColor: AppColors.creme,
      pinned: true,
      stretch: true,

      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: AppColors.tinta),
          tooltip: 'Sair da conta',
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Sair"),
                content: const Text("Tem a certeza que deseja sair?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancelar"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _fazerLogout(context);
                    },
                    child: const Text(
                      "Sair",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],

      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.terracotaSuave),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.tinta.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 58,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: AppColors.tan,
                          backgroundImage:
                              (fotoUrl != null && fotoUrl!.isNotEmpty)
                              ? NetworkImage(fotoUrl!)
                              : null,
                          child: isUploading
                              ? const CircularProgressIndicator()
                              : (fotoUrl == null || fotoUrl!.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColors.tanTexto,
                                      )
                                    : null),
                        ),
                      ),
                      GestureDetector(
                        onTap: isUploading ? null : onCameraTap,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.terracota,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nomeUsuario,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3.0,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    emailUsuario,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.creme, child: _tabBar);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) => false;
}

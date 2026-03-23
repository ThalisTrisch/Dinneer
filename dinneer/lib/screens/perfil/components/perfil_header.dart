import 'package:flutter/material.dart';
import 'package:dinneer/service/sessao/SessionService.dart';
import 'package:dinneer/screens/tela_login.dart';

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
      expandedHeight: 280, // Altura reduzida (sem estrelas)
      backgroundColor: Colors.white,
      pinned: true,
      stretch: true,
      
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          tooltip: 'Sair da conta',
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Sair"),
                content: const Text("Tem a certeza que deseja sair?"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _fazerLogout(context);
                    },
                    child: const Text("Sair", style: TextStyle(color: Colors.red)),
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
            Container(color: Colors.grey[200]),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
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
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: (fotoUrl != null && fotoUrl!.isNotEmpty)
                              ? NetworkImage(fotoUrl!)
                              : null,
                          child: isUploading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : (fotoUrl == null || fotoUrl!.isEmpty
                                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                                  : null),
                        ),
                      ),
                      GestureDetector(
                        onTap: isUploading ? null : onCameraTap,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
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
                      shadows: [Shadow(offset: Offset(0, 1), blurRadius: 3.0, color: Colors.black45)],
                    ),
                  ),
                  Text(
                    emailUsuario,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            )
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }
  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) => false;
}
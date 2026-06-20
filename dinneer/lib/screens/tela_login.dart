import 'package:flutter/material.dart';
import 'package:dinneer/service/usuario/UsuarioService.dart';
import 'package:dinneer/service/sessao/SessionService.dart';
import '../widgets/campo_de_texto.dart';
import '../widgets/mensagens.dart';
import '../widgets/botao_primario.dart';
import 'tela_cadastro.dart';
import '../screens/tela_principal.dart';
import '../service/notification/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _estaCarregando = false;

  void _fazerLogin() async {
    if (_estaCarregando) return;

    final email = _emailController.text;
    final senha = _senhaController.text;

    setState(() => _estaCarregando = true);

    try {
      var resposta = await UsuarioService.login(email, senha);

      if (resposta['dados'] != null) {
        Map<String, dynamic> usuarioLogado;

        if (resposta['dados'] is List) {
          if ((resposta['dados'] as List).isEmpty)
            throw Exception("Lista de dados vazia");
          usuarioLogado = Map<String, dynamic>.from(resposta['dados'][0]);
        } else {
          usuarioLogado = Map<String, dynamic>.from(resposta['dados']);
        }

        final token = usuarioLogado['token'];
        if (token is String && token.isNotEmpty) {
          await SessionService.salvarToken(token);
        }

        if (usuarioLogado['id_usuario'] != null) {
          int id = int.tryParse(usuarioLogado['id_usuario'].toString()) ?? 0;
          await SessionService.salvarUsuarioId(id);
          await SessionService.salvarUsuario(usuarioLogado);

          await NotificationService.initialize(id.toString());

          _enviarNotificacaoTeste();
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TelaPrincipal(dadosUsuario: usuarioLogado),
            ),
          );
        }
      } else {
        _mostrarMensagemErro(
          resposta['Mensagem'] ?? 'Email ou senha inválidos.',
        );
      }
    } catch (e) {
      debugPrint('Erro no login: $e');
      _mostrarMensagemErro('Erro ao conectar. Verifique internet ou IP.');
    } finally {
      if (mounted) setState(() => _estaCarregando = false);
    }
  }

  void _mostrarMensagemErro(String mensagem) {
    if (mounted) Mensagens.erro(context, mensagem);
  }

  void _enviarNotificacaoTeste() async {
    try {
      debugPrint('🧪 Enviando notificação de teste...');

      await Future.delayed(const Duration(seconds: 2));

      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('🔑 FCM Token: $token');

      if (token != null) {
        debugPrint('✅ Token FCM obtido com sucesso!');
        debugPrint('📱 Notificações estão configuradas corretamente');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Notificações configuradas! Token salvo no Firebase.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        debugPrint('❌ Não foi possível obter o token FCM');
      }
    } catch (e) {
      debugPrint('❌ Erro ao testar notificações: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: Colors.black54,
                ),
                const SizedBox(height: 20),
                const Text(
                  'DINNEER',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A MELHOR REFEIÇÃO DE SUA VIDA',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 40),
                CampoDeTextoCustomizado(
                  controller: _emailController,
                  dica: 'Email',
                ),
                const SizedBox(height: 16),
                CampoDeTextoCustomizado(
                  controller: _senhaController,
                  dica: 'Senha',
                  textoObscuro: true,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Não tem uma conta? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TelaCadastro(),
                        ),
                      ),
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                BotaoPrimario(
                  texto: 'LOGIN',
                  onPressed: _fazerLogin,
                  estaCarregando: _estaCarregando,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

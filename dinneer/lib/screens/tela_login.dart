import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dinneer/service/usuario/UsuarioService.dart';
import 'package:dinneer/service/sessao/SessionService.dart';
import '../widgets/campo_de_texto.dart';
import '../widgets/mensagens.dart';
import '../widgets/botao_primario.dart';
import 'tela_cadastro.dart';
import '../screens/tela_principal.dart';
import '../service/notification/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../widgets/googleButtonLogin.dart';

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

  void _fazerLoginGoogle() async {
    if (_estaCarregando) return;

    setState(() => _estaCarregando = true);

    try {
      String emailGoogle;
      String? nomeGoogle;
      String? fotoGoogle;

      if (kIsWeb) {
        // --- Fluxo Web: usa popup direto do Firebase ---
        final googleProvider = GoogleAuthProvider();
        // Força o popup a sempre mostrar o seletor de contas, em vez de
        // reaproveitar silenciosamente a última conta usada.
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        final userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);

        emailGoogle = userCredential.user?.email ?? '';
        nomeGoogle = userCredential.user?.displayName;
        fotoGoogle = userCredential.user?.photoURL;
        if (emailGoogle.isEmpty) {
          await FirebaseAuth.instance.signOut();
          _mostrarMensagemErro('Não foi possível obter o email da conta Google.');
          return;
        }
      } else {
        // --- Fluxo Mobile: usa google_sign_in ---
        final googleSignIn = GoogleSignIn();
        // Limpa a conta em cache para que o seletor de contas apareça toda vez
        // (permite escolher/cadastrar outra conta, não só reentrar na última).
        await googleSignIn.signOut();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          // Usuário cancelou
          return;
        }

        emailGoogle = googleUser.email;
        nomeGoogle = googleUser.displayName;
        fotoGoogle = googleUser.photoUrl;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      // Separa nome e sobrenome a partir do nome da conta Google
      final partesNome = (nomeGoogle ?? '').trim().split(RegExp(r'\s+'));
      final primeiroNome = partesNome.isNotEmpty && partesNome.first.isNotEmpty
          ? partesNome.first
          : 'Usuário';
      final sobrenome =
          partesNome.length > 1 ? partesNome.sublist(1).join(' ') : '';

      // Login OU cadastro num passo só (cria a conta se ainda não existir)
      final respostaDados = await UsuarioService.loginOuCadastroGoogle(
        email: emailGoogle,
        nome: primeiroNome,
        sobrenome: sobrenome,
        foto: fotoGoogle,
      );

      if (respostaDados == null || respostaDados['dados'] == null) {
        _mostrarMensagemErro('Não foi possível entrar com o Google.');
        return;
      }

      Map<String, dynamic> usuarioLogado;
      if (respostaDados['dados'] is List) {
        usuarioLogado =
            Map<String, dynamic>.from(respostaDados['dados'][0]);
      } else {
        usuarioLogado = Map<String, dynamic>.from(respostaDados['dados']);
      }

      // 4. Salva sessão (incluindo o token) e navega para a tela principal
      final tokenGoogle = usuarioLogado['token'];
      if (tokenGoogle is String && tokenGoogle.isNotEmpty) {
        await SessionService.salvarToken(tokenGoogle);
      }

      if (usuarioLogado['id_usuario'] != null) {
        int id = int.tryParse(usuarioLogado['id_usuario'].toString()) ?? 0;
        await SessionService.salvarUsuarioId(id);
        await SessionService.salvarUsuario(usuarioLogado);
        await NotificationService.initialize(id.toString());
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TelaPrincipal(dadosUsuario: usuarioLogado),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro no login com Google: $e');
      _mostrarMensagemErro('Erro ao entrar com Google. Tente novamente.');
    } finally {
      if (mounted) setState(() => _estaCarregando = false);
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
        backgroundColor: AppColors.creme,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: AppColors.creme,
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
                  color: AppColors.terracota,
                ),
                const SizedBox(height: 20),
                Text(
                  'Dinneer',
                  style: AppTypography.serif(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A MELHOR REFEIÇÃO DE SUA VIDA',
                  style: AppTypography.sans(
                    fontSize: 12,
                    color: AppColors.bege,
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
                    Text(
                      'Não tem uma conta? ',
                      style: AppTypography.sans(color: AppColors.bege),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TelaCadastro(),
                        ),
                      ),
                      child: Text(
                        'Cadastre-se',
                        style: AppTypography.sans(
                          fontWeight: FontWeight.w600,
                          color: AppColors.terracota,
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
                GoogleLoginButton(
                  onPressed: _fazerLoginGoogle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

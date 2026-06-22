import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dinneer/service/usuario/UsuarioService.dart';
import 'package:dinneer/service/sessao/SessionService.dart'; // <--- Importante!
import '../widgets/campo_de_texto.dart';
import '../widgets/mensagens.dart';
import '../widgets/botao_primario.dart';
import 'tela_cadastro.dart';
import '../screens/tela_principal.dart';
import '../service/notification/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

        debugPrint(
          'LOGIN SUCESSO. Enviando dados para Principal: $usuarioLogado',
        );

        if (usuarioLogado['id_usuario'] != null) {
          int id = int.tryParse(usuarioLogado['id_usuario'].toString()) ?? 0;
          await SessionService.salvarUsuarioId(id); // <--- Salva no disco!
          await SessionService.salvarUsuario(
            usuarioLogado,
          ); // Salva dados completos
          debugPrint('Sessão salva para o ID: $id');

          await NotificationService.initialize(id.toString());
          
          // 🧪 TESTE: Enviar notificação de teste ao fazer login
          _enviarNotificacaoTeste();
        }
        // ---------------------------------------

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

  // 🧪 TESTE: Envia notificação local para testar o sistema
  void _enviarNotificacaoTeste() async {
    try {
      debugPrint('🧪 Enviando notificação de teste...');
      
      // Aguarda 2 segundos para dar tempo do app inicializar
      await Future.delayed(const Duration(seconds: 2));
      
      // Obtém o token FCM atual
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

      if (kIsWeb) {
        // --- Fluxo Web: usa popup direto do Firebase ---
        final googleProvider = GoogleAuthProvider();
        final userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);

        emailGoogle = userCredential.user?.email ?? '';
        if (emailGoogle.isEmpty) {
          await FirebaseAuth.instance.signOut();
          _mostrarMensagemErro('Não foi possível obter o email da conta Google.');
          return;
        }
      } else {
        // --- Fluxo Mobile: usa google_sign_in ---
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          // Usuário cancelou
          return;
        }

        emailGoogle = googleUser.email;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      // 2. Verifica se o email já tem cadastro no sistema
      final respostaDados = await UsuarioService.verificarEmailExiste(emailGoogle);

      final dados = respostaDados['dados'];
      final existe = dados != null &&
          dados != false &&
          (dados is! List || (dados as List).isNotEmpty);

      if (!existe) {
        await FirebaseAuth.instance.signOut();
        if (!kIsWeb) await GoogleSignIn().signOut();
        _mostrarMensagemErro(
          'Nenhuma conta encontrada para este email. Faça o cadastro primeiro.',
        );
        return;
      }

      if (respostaDados['dados'] == null) {
        _mostrarMensagemErro('Não foi possível carregar os dados do usuário.');
        return;
      }

      Map<String, dynamic> usuarioLogado;
      if (respostaDados['dados'] is List) {
        usuarioLogado =
            Map<String, dynamic>.from(respostaDados['dados'][0]);
      } else {
        usuarioLogado = Map<String, dynamic>.from(respostaDados['dados']);
      }

      // 4. Salva sessão e navega para a tela principal
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

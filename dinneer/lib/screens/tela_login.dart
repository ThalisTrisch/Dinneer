import 'package:flutter/material.dart';
import 'package:dinneer/service/usuario/UsuarioService.dart';
import 'package:dinneer/service/sessao/SessionService.dart'; // <--- Importante!
import '../widgets/campo_de_texto.dart';
import 'cadastro/tela_cadastro.dart';
import '../screens/tela_principal.dart';

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
          debugPrint('Sessão salva para o ID: $id');
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem), backgroundColor: Colors.redAccent),
      );
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _estaCarregando ? null : _fazerLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _estaCarregando
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
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

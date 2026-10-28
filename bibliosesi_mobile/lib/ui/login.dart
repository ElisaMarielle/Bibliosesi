import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../root/sessao.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool carregando = false;
  bool mostrarSenha = false;

  static const String urlBase = 'https://bibliosesi.vercel.app';

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> entrar() async {
    final email = emailController.text.trim().toLowerCase();
    final senha = senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      mostrarMensagem('Preencha o e-mail e a senha.');
      return;
    }

    if (!email.endsWith('@portalsesisp.org.br')) {
      mostrarMensagem(
        'Utilize seu e-mail institucional (@portalsesisp.org.br).',
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      // 1. Realiza o login no backend.
      final respostaLogin = await http
          .post(
            Uri.parse('$urlBase/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'senha': senha,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (respostaLogin.statusCode < 200 ||
          respostaLogin.statusCode >= 300) {
        throw Exception(
          respostaLogin.statusCode == 401 ||
                  respostaLogin.statusCode == 403
              ? 'E-mail ou senha inválidos.'
              : 'Não foi possível fazer login. '
                  'Erro do servidor: ${respostaLogin.statusCode}.',
        );
      }

      final dadosLogin =
          jsonDecode(respostaLogin.body) as Map<String, dynamic>;

      final token = dadosLogin['token']?.toString();

      if (token == null || token.isEmpty) {
        throw Exception('O servidor não retornou o token de acesso.');
      }

      // 2. Decodifica o payload do JWT para obter os dados do usuário.
      final partesToken = token.split('.');

      if (partesToken.length != 3) {
        throw Exception('O servidor retornou um token inválido.');
      }

      final payload = partesToken[1];
      final payloadNormalizado = base64Url.normalize(payload);

      final dadosToken = jsonDecode(
        utf8.decode(base64Url.decode(payloadNormalizado)),
      ) as Map<String, dynamic>;

      final idUsuario = dadosToken['id'];

      if (idUsuario == null) {
        throw Exception('Não foi possível identificar o usuário.');
      }

      // 3. Busca os dados completos do usuário no backend.
      final respostaUsuario = await http
          .get(
            Uri.parse('$urlBase/usuarios/buscar/$idUsuario'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (respostaUsuario.statusCode < 200 ||
          respostaUsuario.statusCode >= 300) {
        throw Exception(
          'Login realizado, mas não foi possível carregar '
          'os dados do usuário. Código: ${respostaUsuario.statusCode}.',
        );
      }

      final respostaDecodificada = jsonDecode(respostaUsuario.body);

      // Aceita um objeto direto ou o usuário dentro de "usuario".
      dynamic usuarioRecebido = respostaDecodificada;

      if (usuarioRecebido is Map<String, dynamic> &&
          usuarioRecebido['usuario'] is Map<String, dynamic>) {
        usuarioRecebido = usuarioRecebido['usuario'];
      }

      if (usuarioRecebido is! Map<String, dynamic>) {
        throw Exception('O servidor retornou dados de usuário inválidos.');
      }

      final usuario = Map<String, dynamic>.from(usuarioRecebido);

      // 4. Mantém a função do backend.
      // Se estiver ausente, tenta usar a função presente no token.
      final funcaoUsuario = usuario['funcao']?.toString().trim();

      final funcaoToken = (
        dadosToken['funcao'] ??
        dadosToken['role']
      )?.toString().trim();

      if (funcaoUsuario == null || funcaoUsuario.isEmpty) {
        if (funcaoToken != null && funcaoToken.isNotEmpty) {
          usuario['funcao'] = funcaoToken.toUpperCase();
        }
      } else {
        usuario['funcao'] = funcaoUsuario.toUpperCase();
      }

      // Salva a sessão para que as outras telas recuperem os dados.
      final preferencias = await SharedPreferences.getInstance();

      await preferencias.setString('token', token);
      await preferencias.setString('usuario', jsonEncode(usuario));

      Sessao.token = token;
      Sessao.usuario = usuario;

      if (!mounted) return;

      // 5. Abre a tela inicial.
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } on FormatException {
      mostrarMensagem(
        'O servidor retornou uma resposta inválida. Tente novamente.',
      );
    } catch (erro) {
      String mensagemErro = erro.toString();

      if (erro is http.ClientException) {
        mensagemErro = 'Não foi possível conectar ao servidor.';
      } else if (erro is Exception) {
        mensagemErro = mensagemErro.replaceFirst('Exception: ', '');
      }

      mostrarMensagem(mensagemErro);
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  void mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF822D2D),
        ),
      );
  }

  void abrirCadastro() {
    Navigator.pushNamed(context, '/cadastro-usuario');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 76,
                    color: Color(0xFFB32A2A),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Login Bibliosesi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Entre com sua conta educacional',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF822D2D),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'E-mail Educacional:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: emailController,
                          enabled: !carregando,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.username,
                            AutofillHints.email,
                          ],
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Digite seu e-mail educacional',
                            hintStyle: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFFB32A2A),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF121212),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.white12,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFB32A2A),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Senha:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: senhaController,
                          enabled: !carregando,
                          obscureText: !mostrarSenha,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [
                            AutofillHints.password,
                          ],
                          onSubmitted: (_) {
                            if (!carregando) entrar();
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Digite sua senha',
                            hintStyle: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFFB32A2A),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  mostrarSenha = !mostrarSenha;
                                });
                              },
                              icon: Icon(
                                mostrarSenha
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF121212),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.white12,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFB32A2A),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: carregando ? null : entrar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF822D2D),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFF593030),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: carregando
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              const Text(
                                'Não é cadastrado? Faça o ',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              GestureDetector(
                                onTap: carregando ? null : abrirCadastro,
                                child: const Text(
                                  'cadastro',
                                  style: TextStyle(
                                    color: Color(0xFFE57373),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'BiblioSesi • Biblioteca digital',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
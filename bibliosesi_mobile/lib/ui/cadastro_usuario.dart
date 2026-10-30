import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  State<CadastroUsuarioPage> createState() =>
      _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  static const String urlBase = 'https://bibliosesi.vercel.app';

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final rmController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  String funcaoSelecionada = 'ALUNO';

  bool carregando = false;
  bool mostrarSenha = false;
  bool mostrarConfirmacao = false;

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    rmController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  void mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: const Color(0xFF822D2D),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> cadastrar() async {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final rmTexto = rmController.text.trim();
    final senha = senhaController.text;
    final confirmarSenha = confirmarSenhaController.text;

    // Validação dos campos.
    if (nome.isEmpty ||
        email.isEmpty ||
        rmTexto.isEmpty ||
        senha.isEmpty ||
        confirmarSenha.isEmpty) {
      mostrarMensagem('Preencha todos os campos.');
      return;
    }

    if (nome.length < 2) {
      mostrarMensagem('Digite um nome válido.');
      return;
    }

    if (!email.endsWith('@portalsesisp.org.br')) {
      mostrarMensagem(
        'Utilize um e-mail institucional '
        '(@portalsesisp.org.br).',
      );
      return;
    }

    if (!RegExp(r'^\d{4}$').hasMatch(rmTexto)) {
      mostrarMensagem('O RM deve conter exatamente 4 números.');
      return;
    }

    if (senha != confirmarSenha) {
      mostrarMensagem('As senhas não coincidem.');
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      // Envia os dados para o backend publicado.
      final resposta = await http
          .post(
            Uri.parse('$urlBase/usuarios/cadastrar'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'nome': nome,
              'email': email,
              'senha': senha,
              'rm': int.parse(rmTexto),
              'funcao': funcaoSelecionada,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (resposta.statusCode >= 200 &&
          resposta.statusCode < 300) {
        if (!mounted) return;

        // Cadastro realizado: retorna para a tela de login.
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              icon: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFFE57373),
                size: 52,
              ),
              title: const Text(
                'Cadastro realizado!',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Sua conta foi cadastrada com sucesso. '
                'Agora você pode entrar no BiblioSesi.',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF822D2D),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Ir para o login'),
                  ),
                ),
              ],
            );
          },
        );

        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      } else {
        // Tenta mostrar a mensagem devolvida pela API.
        String mensagem =
            'Não foi possível realizar o cadastro '
            '(HTTP ${resposta.statusCode}).';

        try {
          final dados = jsonDecode(resposta.body);

          if (dados is Map<String, dynamic>) {
            final mensagemApi =
                dados['mensagem'] ??
                dados['message'] ??
                dados['erro'] ??
                dados['error'];

            if (mensagemApi != null) {
              mensagem = mensagemApi.toString();
            }
          }
        } catch (_) {
          // Mantém a mensagem padrão se a resposta não for JSON.
        }

        mostrarMensagem(mensagem);
      }
    } catch (erro) {
      if (erro is http.ClientException) {
        mostrarMensagem(
          'Não foi possível conectar ao servidor.',
        );
      } else if (erro is FormatException) {
        mostrarMensagem('Verifique os dados informados.');
      } else {
        mostrarMensagem(
          'Ocorreu um erro ao cadastrar. '
          'Verifique sua conexão e tente novamente.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  InputDecoration decoracaoCampo({
    required String titulo,
    required String dica,
    required IconData icone,
    Widget? sufixo,
  }) {
    return InputDecoration(
      labelText: titulo,
      hintText: dica,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(
        color: Colors.white38,
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icone,
        color: const Color(0xFFE57373),
      ),
      suffixIcon: sufixo,
      filled: true,
      fillColor: const Color(0xFF121212),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE57373),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Criar conta'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 20,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 68,
                    color: Color(0xFFB32A2A),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cadastro BiblioSesi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crie sua conta para acessar a biblioteca.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF822D2D),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: nomeController,
                          enabled: !carregando,
                          textCapitalization:
                              TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.name,
                          ],
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: decoracaoCampo(
                            titulo: 'Nome completo',
                            dica: 'Digite seu nome',
                            icone: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 18),

                        TextField(
                          controller: emailController,
                          enabled: !carregando,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.email,
                          ],
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: decoracaoCampo(
                            titulo: 'E-mail educacional',
                            dica: 'seuemail@portalsesisp.org.br',
                            icone: Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 18),

                        TextField(
                          controller: rmController,
                          enabled: !carregando,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          maxLength: 4,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: decoracaoCampo(
                            titulo: 'RM',
                            dica: 'Digite os 4 números do RM',
                            icone: Icons.badge_outlined,
                          ).copyWith(counterText: ''),
                        ),
                        const SizedBox(height: 18),

                        const Text(
                          'Tipo de usuário',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Aluno'),
                              selected:
                                  funcaoSelecionada == 'ALUNO',
                              onSelected: carregando
                                  ? null
                                  : (selecionado) {
                                      if (selecionado) {
                                        setState(() {
                                          funcaoSelecionada = 'ALUNO';
                                        });
                                      }
                                    },
                              selectedColor:
                                  const Color(0xFF822D2D),
                              backgroundColor:
                                  const Color(0xFF121212),
                              labelStyle: TextStyle(
                                color: funcaoSelecionada == 'ALUNO'
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                              side: const BorderSide(
                                color: Colors.white24,
                              ),
                            ),
                            ChoiceChip(
                              label: const Text('Administrador'),
                              selected:
                                  funcaoSelecionada == 'ADM',
                              onSelected: carregando
                                  ? null
                                  : (selecionado) {
                                      if (selecionado) {
                                        setState(() {
                                          funcaoSelecionada = 'ADM';
                                        });
                                      }
                                    },
                              selectedColor:
                                  const Color(0xFF822D2D),
                              backgroundColor:
                                  const Color(0xFF121212),
                              labelStyle: TextStyle(
                                color: funcaoSelecionada == 'ADM'
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                              side: const BorderSide(
                                color: Colors.white24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        TextField(
                          controller: senhaController,
                          enabled: !carregando,
                          obscureText: !mostrarSenha,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.newPassword,
                          ],
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: decoracaoCampo(
                            titulo: 'Senha',
                            dica: 'Crie uma senha',
                            icone: Icons.lock_outline,
                            sufixo: IconButton(
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
                          ),
                        ),
                        const SizedBox(height: 18),

                        TextField(
                          controller: confirmarSenhaController,
                          enabled: !carregando,
                          obscureText: !mostrarConfirmacao,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            if (!carregando) cadastrar();
                          },
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: decoracaoCampo(
                            titulo: 'Confirmar senha',
                            dica: 'Digite a senha novamente',
                            icone: Icons.lock_reset_outlined,
                            sufixo: IconButton(
                              onPressed: () {
                                setState(() {
                                  mostrarConfirmacao =
                                      !mostrarConfirmacao;
                                });
                              },
                              icon: Icon(
                                mostrarConfirmacao
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed:
                                carregando ? null : cadastrar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF822D2D),
                              disabledBackgroundColor:
                                  const Color(0xFF593030),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                            ),
                            child: carregando
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Cadastrar',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            const Text(
                              'Já possui uma conta? ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: carregando
                                  ? null
                                  : () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/login',
                                      );
                                    },
                              child: const Text(
                                'Faça login',
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
                      ],
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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../root/pallet.dart';
import '../root/sessao.dart';

const String urlPerfil = 'https://bibliosesi.vercel.app';

class PerfilPage extends StatefulWidget {
  final int? usuarioId;

  const PerfilPage({super.key, this.usuarioId});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final rmController = TextEditingController();

  Map<String, dynamic>? usuario;
  bool carregando = true;
  bool salvando = false;
  bool editando = false;

  @override
  void initState() {
    super.initState();
    carregarUsuario();
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    rmController.dispose();
    super.dispose();
  }

  Future<void> carregarUsuario() async {
    final usuarioSessao = Sessao.usuario;

    final id = widget.usuarioId ?? usuarioSessao?['id'];

    if (id == null) {
      setState(() {
        carregando = false;
      });
      return;
    }

    try {
      // Busca os dados na API, como o perfil do site.
      final resposta = await http
          .get(
            Uri.parse('$urlPerfil/usuarios/buscar/$id'),
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('PERFIL STATUS: ${resposta.statusCode}');
      debugPrint('PERFIL RESPOSTA: ${resposta.body}');

      if (resposta.statusCode < 200 ||
          resposta.statusCode >= 300) {
        throw Exception(
          'Não foi possível carregar o perfil '
          '(HTTP ${resposta.statusCode}).',
        );
      }

      final dados = jsonDecode(resposta.body);

      if (dados is! Map) {
        throw Exception('Os dados do perfil são inválidos.');
      }

      final resultado = dados['usuario'] is Map
          ? Map<String, dynamic>.from(dados['usuario'])
          : Map<String, dynamic>.from(dados);

      if (resultado['id'] == null) {
        resultado['id'] = id;
      }

      // Mantém o perfil atualizado na sessão compartilhada.
      Sessao.usuario = resultado;

      if (!mounted) return;

      setState(() {
        usuario = resultado;
        preencherCampos();
        carregando = false;
      });
    } catch (erro) {
      debugPrint('ERRO AO CARREGAR PERFIL: $erro');

      if (!mounted) return;

      // Se a API falhar, tenta exibir os dados já carregados no login.
      if (usuarioSessao != null &&
          usuarioSessao['id'] != null) {
        setState(() {
          usuario = Map<String, dynamic>.from(usuarioSessao);
          preencherCampos();
          carregando = false;
        });

        mostrarMensagem(
          'Não foi possível atualizar os dados pela API. '
          'Exibindo os dados da sessão.',
        );
      } else {
        setState(() {
          carregando = false;
        });

        mostrarMensagem(
          'Não foi possível carregar o perfil. Entre novamente.',
        );
      }
    }
  }

  void preencherCampos() {
    if (usuario == null) return;

    nomeController.text = usuario!['nome']?.toString() ?? '';
    emailController.text = usuario!['email']?.toString() ?? '';
    rmController.text = usuario!['rm']?.toString() ?? '';
  }

  Future<void> salvarAlteracoes() async {
    if (usuario == null || usuario!['id'] == null) {
      mostrarMensagem('Usuário não encontrado. Entre novamente.');
      return;
    }

    final nome = nomeController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final rmTexto = rmController.text.trim();

    if (nome.isEmpty || email.isEmpty || rmTexto.isEmpty) {
      mostrarMensagem('Preencha todos os campos.');
      return;
    }

    if (!email.endsWith('@portalsesisp.org.br')) {
      mostrarMensagem(
        'Use seu e-mail institucional @portalsesisp.org.br.',
      );
      return;
    }

    if (!RegExp(r'^\d{4}$').hasMatch(rmTexto)) {
      mostrarMensagem('O RM deve conter exatamente 4 números.');
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final id = usuario!['id'];

      final resposta = await http
          .put(
            Uri.parse('$urlPerfil/usuarios/atualizar/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (Sessao.token != null)
                'Authorization': 'Bearer ${Sessao.token}',
            },
            body: jsonEncode({
              'nome': nome,
              'email': email,
              'rm': int.parse(rmTexto),
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('ATUALIZAR PERFIL STATUS: ${resposta.statusCode}');
      debugPrint('ATUALIZAR PERFIL RESPOSTA: ${resposta.body}');

      if (resposta.statusCode < 200 ||
          resposta.statusCode >= 300) {
        String mensagem =
            'Não foi possível atualizar o perfil '
            '(HTTP ${resposta.statusCode}).';

        try {
          final dados = jsonDecode(resposta.body);

          if (dados is Map && dados['mensagem'] != null) {
            mensagem = dados['mensagem'].toString();
          }
        } catch (_) {}

        throw Exception(mensagem);
      }

      // Usa os dados retornados pela API quando disponíveis.
      Map<String, dynamic> usuarioAtualizado = {
        ...usuario!,
        'nome': nome,
        'email': email,
        'rm': int.parse(rmTexto),
      };

      try {
        final dados = jsonDecode(resposta.body);

        if (dados is Map) {
          final retorno = dados['usuario'];

          if (retorno is Map) {
            usuarioAtualizado = {
              ...usuarioAtualizado,
              ...Map<String, dynamic>.from(retorno),
            };
          } else if (dados['id'] != null) {
            usuarioAtualizado = {
              ...usuarioAtualizado,
              ...Map<String, dynamic>.from(dados),
            };
          }
        }
      } catch (_) {}

      Sessao.usuario = usuarioAtualizado;

      if (!mounted) return;

      setState(() {
        usuario = usuarioAtualizado;
        preencherCampos();
        editando = false;
      });

      mostrarMensagem('Perfil atualizado com sucesso.');
    } catch (erro) {
      debugPrint('ERRO AO ATUALIZAR PERFIL: $erro');

      if (!mounted) return;

      String mensagem = erro.toString();

      if (mensagem.startsWith('Exception: ')) {
        mensagem = mensagem.substring('Exception: '.length);
      }

      mostrarMensagem(mensagem);
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  void mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  void sair() {
    Sessao.limpar();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  Widget campoPerfil({
    required String rotulo,
    required TextEditingController controller,
    required IconData icone,
    TextInputType? teclado,
    bool somenteLeitura = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: teclado,
        readOnly: !editando || somenteLeitura,
        decoration: InputDecoration(
          labelText: rotulo,
          prefixIcon: Icon(icone),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text('Meu perfil'),
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: sair,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : usuario == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.account_circle_outlined,
                          size: 70,
                          color: AppPalette.primary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Não foi possível carregar seu perfil.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/login',
                            );
                          },
                          child: const Text('Ir para o login'),
                        ),
                      ],
                    ),
                  ),
                )
              : SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 450,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            const CircleAvatar(
                              radius: 48,
                              backgroundColor: AppPalette.primary,
                              child: Icon(
                                Icons.person,
                                size: 56,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              usuario!['nome']?.toString() ??
                                  'Usuário',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppPalette.text,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              usuario!['funcao']?.toString() ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppPalette.gray,
                              ),
                            ),
                            const SizedBox(height: 28),
                            campoPerfil(
                              rotulo: 'Nome completo',
                              controller: nomeController,
                              icone: Icons.person_outline,
                            ),
                            campoPerfil(
                              rotulo: 'E-mail educacional',
                              controller: emailController,
                              icone: Icons.email_outlined,
                              teclado: TextInputType.emailAddress,
                            ),
                            campoPerfil(
                              rotulo: 'RM',
                              controller: rmController,
                              icone: Icons.badge_outlined,
                              teclado: TextInputType.number,
                            ),
                            const SizedBox(height: 8),
                            if (!editando)
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    editando = true;
                                  });
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Editar perfil'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppPalette.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize:
                                      const Size.fromHeight(48),
                                ),
                              )
                            else ...[
                              ElevatedButton.icon(
                                onPressed:
                                    salvando ? null : salvarAlteracoes,
                                icon: const Icon(Icons.save),
                                label: Text(
                                  salvando
                                      ? 'Salvando...'
                                      : 'Salvar alterações',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppPalette.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize:
                                      const Size.fromHeight(48),
                                ),
                              ),
                              TextButton(
                                onPressed: salvando
                                    ? null
                                    : () {
                                        setState(() {
                                          preencherCampos();
                                          editando = false;
                                        });
                                      },
                                child: const Text('Cancelar'),
                              ),
                            ],
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: carregarUsuario,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Atualizar dados'),
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
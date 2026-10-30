
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CadastroLivro extends StatefulWidget {
  const CadastroLivro({super.key});

  @override
  State<CadastroLivro> createState() => _CadastroLivroState();
}

class _CadastroLivroState extends State<CadastroLivro> {
  static const String urlBase = 'https://bibliosesi.vercel.app';

  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();
  final autorController = TextEditingController();
  final publicacaoController = TextEditingController();
  final generoController = TextEditingController();
  final editoraController = TextEditingController();
  final imagemController = TextEditingController();

  bool carregando = false;
  bool verificandoSessao = true;
  String? token;

  @override
  void initState() {
    super.initState();
    verificarSessao();
  }

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    autorController.dispose();
    publicacaoController.dispose();
    generoController.dispose();
    editoraController.dispose();
    imagemController.dispose();
    super.dispose();
  }

  Future<void> verificarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenSalvo = prefs.getString('token');
    final usuarioSalvo = prefs.getString('usuario');

    bool administrador = false;

    if (usuarioSalvo != null) {
      try {
        final usuario =
            jsonDecode(usuarioSalvo) as Map<String, dynamic>;
        administrador = usuario['funcao'] == 'ADM';
      } catch (_) {
        administrador = false;
      }
    }

    if (!mounted) return;

    setState(() {
      token = tokenSalvo;
      verificandoSessao = false;
    });

    if (tokenSalvo == null ||
        tokenSalvo.isEmpty ||
        !administrador) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !administrador
                  ? 'Somente administradores podem cadastrar livros.'
                  : 'Sua sessão expirou. Faça login novamente.',
            ),
            backgroundColor: const Color(0xFF822D2D),
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/catalogo',
          (route) => false,
        );
      });
    }
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

  Future<void> cadastrarLivro() async {
    final titulo = tituloController.text.trim();
    final descricao = descricaoController.text.trim();
    final autor = autorController.text.trim();
    final publicacao = publicacaoController.text.trim();
    final genero = generoController.text.trim();
    final editora = editoraController.text.trim();
    final imagem = imagemController.text.trim();

    if (titulo.isEmpty ||
        descricao.isEmpty ||
        autor.isEmpty ||
        publicacao.isEmpty ||
        genero.isEmpty ||
        editora.isEmpty ||
        imagem.isEmpty) {
      mostrarMensagem('Preencha todos os campos.');
      return;
    }

    final uriImagem = Uri.tryParse(imagem);

    if (uriImagem == null ||
        !uriImagem.hasAuthority ||
        (uriImagem.scheme != 'https' &&
            uriImagem.scheme != 'http')) {
      mostrarMensagem(
        'Informe um endereço HTTP ou HTTPS válido para a capa.',
      );
      return;
    }

    if (token == null || token!.isEmpty) {
      mostrarMensagem('Sua sessão expirou. Faça login novamente.');
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      final resposta = await http
          .post(
            Uri.parse('$urlBase/livros/cadastrar'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'titulo': titulo,
              'descricao': descricao,
              'autor': autor,
              'publicacao': publicacao,
              'genero': genero,
              'editora': editora,
              'imagem': imagem,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (resposta.statusCode < 200 ||
          resposta.statusCode >= 300) {
        String mensagem =
            'Não foi possível cadastrar o livro '
            '(HTTP ${resposta.statusCode}).';

        try {
          final dados = jsonDecode(resposta.body);

          if (dados is Map<String, dynamic>) {
            final detalhe =
                dados['mensagem'] ??
                dados['message'] ??
                dados['erro'] ??
                dados['error'];

            if (detalhe != null) {
              mensagem = detalhe.toString();
            }
          }
        } catch (_) {
          // Mantém a mensagem padrão se a API não retornar JSON.
        }

        throw Exception(mensagem);
      }

      if (!mounted) return;

      mostrarMensagem('Livro cadastrado com sucesso!');

      // Retorna ao catálogo, que poderá atualizar a lista.
      Navigator.pop(context, true);
    } catch (e) {
      mostrarMensagem(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  InputDecoration decoracao({
    required String titulo,
    required String dica,
    required IconData icone,
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

  Widget campo({
    required TextEditingController controller,
    required String titulo,
    required String dica,
    required IconData icone,
    int linhas = 1,
    TextInputType teclado = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      enabled: !carregando,
      keyboardType: teclado,
      minLines: linhas == 1 ? 1 : linhas,
      maxLines: linhas,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(color: Colors.white),
      decoration: decoracao(
        titulo: titulo,
        dica: dica,
        icone: icone,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (verificandoSessao) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE57373),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF822D2D),
        foregroundColor: Colors.white,
        title: const Text('Cadastrar livro'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
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
                    const Icon(
                      Icons.library_add_outlined,
                      size: 65,
                      color: Color(0xFFE57373),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Cadastre um livro!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Preencha as informações do livro para '
                      'adicioná-lo ao catálogo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 28),

                    campo(
                      controller: tituloController,
                      titulo: 'Título',
                      dica: 'Digite o título do livro',
                      icone: Icons.menu_book_outlined,
                    ),
                    const SizedBox(height: 16),

                    campo(
                      controller: descricaoController,
                      titulo: 'Sinopse',
                      dica: 'Descreva a história do livro',
                      icone: Icons.description_outlined,
                      linhas: 4,
                    ),
                    const SizedBox(height: 16),

                    campo(
                      controller: autorController,
                      titulo: 'Autor',
                      dica: 'Nome do autor',
                      icone: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    campo(
                      controller: publicacaoController,
                      titulo: 'Data de publicação',
                      dica: 'Ex.: 15/05/2020 ou 2020',
                      icone: Icons.calendar_month_outlined,
                    ),
                    const SizedBox(height: 16),

                    campo(
                      controller: generoController,
                      titulo: 'Gêneros',
                      dica: 'Ex.: Romance, Suspense',
                      icone: Icons.category_outlined,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Para vários gêneros, separe os nomes por vírgula.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),

                    campo(
                      controller: editoraController,
                      titulo: 'Editora',
                      dica: 'Nome da editora',
                      icone: Icons.business_outlined,
                    ),
                    const SizedBox(height: 16),

                    campo(
                      controller: imagemController,
                      titulo: 'Imagem da capa',
                      dica: 'Cole o link da imagem',
                      icone: Icons.image_outlined,
                      teclado: TextInputType.url,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Use um link direto para uma imagem acessível '
                      'pela internet.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed:
                            carregando ? null : cadastrarLivro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF822D2D),
                          disabledBackgroundColor:
                              const Color(0xFF593030),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: carregando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          carregando
                              ? 'Cadastrando...'
                              : 'Cadastrar livro',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    OutlinedButton(
                      onPressed: carregando
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(
                          color: Colors.white24,
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
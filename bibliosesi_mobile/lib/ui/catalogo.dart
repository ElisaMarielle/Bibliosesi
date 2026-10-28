import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  static const String urlBase = 'https://bibliosesi.vercel.app';

  final TextEditingController pesquisaController =
      TextEditingController();

  final List<String> generos = [
    'Todos',
    'Ação',
    'Aventura',
    'Crônicas',
    'Fantasia',
    'Ficção',
    'Ficção científica',
    'Poesia',
    'Romance',
    'Suspense',
    'Terror',
  ];

  List<Map<String, dynamic>> livros = [];
  Set<String> favoritos = {};

  String filtroSelecionado = 'Todos';
  String termoPesquisa = '';
  String? token;
  Map<String, dynamic>? usuario;

  bool carregando = true;
  String? erroCarregamento;

  @override
  void initState() {
    super.initState();
    inicializar();
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  Future<void> inicializar() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString('token');

    final usuarioSalvo = prefs.getString('usuario');

    if (usuarioSalvo != null) {
      try {
        usuario = Map<String, dynamic>.from(
          jsonDecode(usuarioSalvo) as Map,
        );
      } catch (_) {
        usuario = null;
      }
    }

    final idUsuario = usuario?['id'];

    final chave = idUsuario != null
        ? 'livrosFavoritados_$idUsuario'
        : 'livrosFavoritados_visitante';

    favoritos = (prefs.getStringList(chave) ?? []).toSet();

    if (!mounted) return;

    setState(() {});

    await carregarLivros();
  }

  // Reconhece as formas comuns da função de administrador.
  bool get ehAdministrador {
    final funcao = usuario?['funcao']
        ?.toString()
        .trim()
        .toUpperCase();

    return funcao == 'ADM' ||
        funcao == 'ADMIN' ||
        funcao == 'ADMINISTRADOR';
  }

  Map<String, String> get headers => {
        'Accept': 'application/json',
        if (token != null && token!.isNotEmpty)
          'Authorization': 'Bearer $token',
      };

  Future<void> carregarLivros() async {
    if (mounted) {
      setState(() {
        carregando = true;
        erroCarregamento = null;
      });
    }

    try {
      final resposta = await http
          .get(
            Uri.parse('$urlBase/livros/listar'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (resposta.statusCode < 200 ||
          resposta.statusCode >= 300) {
        throw Exception(
          'Erro ao carregar livros: HTTP ${resposta.statusCode}.',
        );
      }

      final dados = jsonDecode(resposta.body);

      dynamic listaRecebida = dados;

      if (dados is Map<String, dynamic>) {
        listaRecebida = dados['livros'] ?? dados['data'];
      }

      if (listaRecebida is! List) {
        throw Exception(
          'A resposta da API não contém uma lista de livros.',
        );
      }

      final resultado = <Map<String, dynamic>>[];

      for (final item in listaRecebida) {
        if (item is Map) {
          resultado.add(Map<String, dynamic>.from(item));
        }
      }

      if (!mounted) return;

      setState(() {
        livros = resultado;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
        erroCarregamento =
            e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<Map<String, dynamic>> get livrosFiltrados {
    final termo = termoPesquisa.trim().toLowerCase();

    return livros.where((livro) {
      final titulo = '${livro['titulo'] ?? ''}';
      final autor = '${livro['autor'] ?? ''}';
      final descricao = '${livro['descricao'] ?? ''}';
      final publicacao = '${livro['publicacao'] ?? ''}';
      final genero = '${livro['genero'] ?? ''}';

      final correspondePesquisa = [
        titulo,
        autor,
        descricao,
        publicacao,
        genero,
        '${livro['editora'] ?? ''}',
      ].any((texto) => texto.toLowerCase().contains(termo));

      final listaGeneros = genero
          .split(',')
          .map((g) => g.trim().toLowerCase())
          .toList();

      final correspondeFiltro =
          filtroSelecionado == 'Todos' ||
          (filtroSelecionado == 'Favoritados'
              ? favoritos.contains('${livro['id']}')
              : listaGeneros.contains(
                  filtroSelecionado.toLowerCase(),
                ));

      return correspondePesquisa && correspondeFiltro;
    }).toList();
  }

  bool estaEmprestado(Map<String, dynamic> livro) {
    final emprestimos = livro['emprestimos'];

    if (emprestimos is! List || emprestimos.isEmpty) {
      return false;
    }

    final agora = DateTime.now();

    return emprestimos.any((item) {
      if (item is! Map || item['data_devolucao'] == null) {
        return false;
      }

      final data = DateTime.tryParse(
        item['data_devolucao'].toString(),
      );

      return data != null && data.isAfter(agora);
    });
  }

  Future<void> alternarFavorito(Map<String, dynamic> livro) async {
    final id = '${livro['id']}';

    setState(() {
      if (favoritos.contains(id)) {
        favoritos.remove(id);
      } else {
        favoritos.add(id);
      }
    });

    final prefs = await SharedPreferences.getInstance();

    final idUsuario = usuario?['id'];

    final chave = idUsuario != null
        ? 'livrosFavoritados_$idUsuario'
        : 'livrosFavoritados_visitante';

    await prefs.setStringList(chave, favoritos.toList());
  }

  void abrirCadastro() {
    if (!ehAdministrador) {
      mensagem('Somente administradores podem cadastrar livros.');
      return;
    }

    Navigator.pushNamed(context, '/cadastro').then((_) {
      carregarLivros();
    });
  }

  void mensagem(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: const Color(0xFF822D2D),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> emprestar(Map<String, dynamic> livro) async {
    final idLivro = int.tryParse('${livro['id']}');
    final idUsuario = int.tryParse('${usuario?['id']}');

    if (token == null || token!.isEmpty) {
      mensagem('Sua sessão expirou. Faça login novamente.');
      return;
    }

    if (idLivro == null || idUsuario == null) {
      mensagem('Não foi possível identificar o livro ou o usuário.');
      return;
    }

    if (estaEmprestado(livro)) {
      mensagem('Este livro já está emprestado.');
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Confirmar empréstimo',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Deseja emprestar "${livro['titulo']}" por 7 dias?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF822D2D),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Emprestar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      final dataEmprestimo = DateTime.now();
      final dataDevolucao = dataEmprestimo.add(
        const Duration(days: 7),
      );

      final resposta = await http
          .post(
            Uri.parse('$urlBase/emprestimos/cadastrar'),
            headers: {
              ...headers,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'usuarioId': idUsuario,
              'livroId': idLivro,
              'data_emprestimo':
                  dataEmprestimo.toUtc().toIso8601String(),
              'data_devolucao':
                  dataDevolucao.toUtc().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      dynamic dados;

      try {
        dados = jsonDecode(resposta.body);
      } catch (_) {
        dados = null;
      }

      if (resposta.statusCode < 200 ||
          resposta.statusCode >= 300) {
        final detalhe = dados is Map
            ? dados['mensagem'] ?? dados['message']
            : null;

        throw Exception(
          detalhe?.toString() ??
              'Não foi possível realizar o empréstimo '
                  '(HTTP ${resposta.statusCode}).',
        );
      }

      if (!mounted) return;

      Navigator.pop(context);

      mensagem('Empréstimo realizado com sucesso!');

      await carregarLivros();
    } catch (e) {
      mensagem(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> excluirLivro(Map<String, dynamic> livro) async {
    if (!ehAdministrador) {
      mensagem('Você não tem permissão para excluir livros.');
      return;
    }

    final id = livro['id'];

    if (id == null) {
      mensagem('Não foi possível identificar o livro.');
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Excluir livro',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Deseja realmente excluir "${livro['titulo']}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      final resposta = await http.delete(
        Uri.parse('$urlBase/livros/excluir/$id'),
        headers: headers,
      );

      if (resposta.statusCode < 200 ||
          resposta.statusCode >= 300) {
        throw Exception(
          'Erro ao excluir livro: HTTP ${resposta.statusCode}.',
        );
      }

      // Remove o livro da lista de favoritos, se necessário.
      final idTexto = '$id';

      if (favoritos.contains(idTexto)) {
        favoritos.remove(idTexto);

        final prefs = await SharedPreferences.getInstance();
        final idUsuario = usuario?['id'];

        final chave = idUsuario != null
            ? 'livrosFavoritados_$idUsuario'
            : 'livrosFavoritados_visitante';

        await prefs.setStringList(chave, favoritos.toList());
      }

      if (!mounted) return;

      Navigator.pop(context);
      mensagem('Livro excluído com sucesso.');

      await carregarLivros();
    } catch (e) {
      mensagem(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Widget construirCapa(
    Map<String, dynamic> livro, {
    double altura = 190,
  }) {
    final imagem = '${livro['imagem'] ?? ''}'.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: altura,
        width: double.infinity,
        color: const Color(0xFF292929),
        child: imagem.isEmpty
            ? const Icon(
                Icons.menu_book_rounded,
                size: 60,
                color: Colors.white38,
              )
            : Image.network(
                imagem,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 50,
                      color: Colors.white38,
                    ),
                  );
                },
              ),
      ),
    );
  }

  void abrirDetalhes(Map<String, dynamic> livro) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, atualizarModal) {
            final emprestado = estaEmprestado(livro);
            final favoritado = favoritos.contains('${livro['id']}');

            return Dialog(
              backgroundColor: const Color(0xFF1E1E1E),
              insetPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 170,
                        child: construirCapa(
                          livro,
                          altura: 220,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${livro['titulo'] ?? 'Sem título'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${livro['descricao'] ?? 'Sem descrição disponível.'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    detalheTexto('Autor', livro['autor']),
                    detalheTexto('Publicação', livro['publicacao']),
                    detalheTexto('Editora', livro['editora']),
                    detalheTexto('Gênero', livro['genero']),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: emprestado
                            ? Colors.orange.withValues(alpha: 0.15)
                            : Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        emprestado ? 'Emprestado' : 'Disponível',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: emprestado
                              ? Colors.orangeAccent
                              : Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            await alternarFavorito(livro);
                            atualizarModal(() {});
                          },
                          icon: Icon(
                            favoritado
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: favoritado
                                ? Colors.pinkAccent
                                : Colors.white70,
                          ),
                          label: Text(
                            favoritado ? 'Favoritado' : 'Favoritar',
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: emprestado
                              ? null
                              : () => emprestar(livro),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF822D2D),
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.bookmark_add_outlined),
                          label: Text(
                            emprestado ? 'Indisponível' : 'Emprestar',
                          ),
                        ),
                        if (ehAdministrador)
                          OutlinedButton.icon(
                            onPressed: () => excluirLivro(livro),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            label: const Text('Excluir'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget detalheTexto(String titulo, dynamic valor) {
    final texto = valor?.toString().trim() ?? '';

    if (texto.isEmpty || texto == 'null') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$titulo: $texto',
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = livrosFiltrados;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF822D2D),
        foregroundColor: Colors.white,
        title: const Text('Catálogo'),
        actions: [
          IconButton(
            onPressed: carregarLivros,
            tooltip: 'Atualizar catálogo',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: ehAdministrador
          ? FloatingActionButton.extended(
              onPressed: abrirCadastro,
              backgroundColor: const Color(0xFF822D2D),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar livro'),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: TextField(
                controller: pesquisaController,
                onChanged: (valor) {
                  setState(() {
                    termoPesquisa = valor;
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Pesquise título, autor, ano...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFE57373),
                  ),
                  suffixIcon: termoPesquisa.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            pesquisaController.clear();
                            setState(() {
                              termoPesquisa = '';
                            });
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white70,
                          ),
                        ),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    color: Color(0xFFE57373),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: filtroSelecionado,
                      dropdownColor: const Color(0xFF1E1E1E),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'Todos',
                          child: Text('Todos os livros'),
                        ),
                        const DropdownMenuItem(
                          value: 'Favoritados',
                          child: Text('Favoritados'),
                        ),
                        ...generos.skip(1).map(
                          (genero) => DropdownMenuItem(
                            value: genero,
                            child: Text(genero),
                          ),
                        ),
                      ],
                      onChanged: (valor) {
                        if (valor == null) return;
                        setState(() {
                          filtroSelecionado = valor;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (carregando) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE57373),
                      ),
                    );
                  }

                  if (erroCarregamento != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_outlined,
                              size: 54,
                              color: Colors.white38,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              erroCarregamento!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton.icon(
                              onPressed: carregarLivros,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (lista.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.menu_book_outlined,
                              size: 60,
                              color: Colors.white38,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              livros.isEmpty
                                  ? 'Nenhum livro cadastrado.'
                                  : 'Nenhum livro encontrado.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            if (ehAdministrador && livros.isEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: abrirCadastro,
                                icon: const Icon(Icons.add),
                                label: const Text(
                                  'Cadastrar primeiro livro',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: carregarLivros,
                    color: const Color(0xFF822D2D),
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 90),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 230,
                        mainAxisExtent: 335,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: lista.length,
                      itemBuilder: (context, index) {
                        final livro = lista[index];
                        final favoritado =
                            favoritos.contains('${livro['id']}');
                        final emprestado = estaEmprestado(livro);

                        return InkWell(
                          onTap: () => abrirDetalhes(livro),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white10,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: construirCapa(livro),
                                      ),
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: Material(
                                          color: Colors.black54,
                                          shape: const CircleBorder(),
                                          child: IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            onPressed: () =>
                                                alternarFavorito(livro),
                                            icon: Icon(
                                              favoritado
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: favoritado
                                                  ? Colors.pinkAccent
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${livro['titulo'] ?? 'Sem título'}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${livro['autor'] ?? 'Autor não informado'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 9,
                                      color: emprestado
                                          ? Colors.orangeAccent
                                          : Colors.greenAccent,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        emprestado
                                            ? 'Emprestado'
                                            : 'Disponível',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: emprestado
                                              ? Colors.orangeAccent
                                              : Colors.greenAccent,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.open_in_new,
                                      color: Colors.white38,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
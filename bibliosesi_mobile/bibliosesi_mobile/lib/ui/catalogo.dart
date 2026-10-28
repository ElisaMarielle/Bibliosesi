
import 'package:flutter/material.dart';

import '../root/pallet.dart';
import '../models/models.dart';
import 'login.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final TextEditingController pesquisaController =
      TextEditingController();

  String filtroSelecionado = 'Nenhum';
  List<Livro> livros = [];
  final Set<int> solicitando = {};

  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    if (!mounted) return;

    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final lista = await Session.api.listarLivros();

      if (!mounted) return;

      setState(() {
        livros = lista;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        erro = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  Future<void> _solicitarEmprestimo(Livro livro) async {
    final usuario = Session.usuario;
    final livroId = livro.id;
    final usuarioId = usuario?.id;

    if (usuarioId == null || livroId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível identificar o usuário ou o livro. '
            'Verifique seu login e tente novamente.',
          ),
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Solicitar empréstimo'),
        content: Text(
          'Deseja solicitar o empréstimo do livro '
          '"${livro.titulo}"?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() {
      solicitando.add(livroId);
    });

    try {
      await Session.api.solicitarEmprestimo(
        usuarioId: usuarioId,
        livroId: livroId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Solicitação de empréstimo enviada com sucesso!',
          ),
        ),
      );

      await carregar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível solicitar o empréstimo: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          solicitando.remove(livroId);
        });
      }
    }
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  List<Livro> get livrosFiltrados {
    final pesquisa =
        pesquisaController.text.toLowerCase().trim();

    return livros.where((livro) {
      final texto = [
        livro.titulo,
        livro.descricao,
        livro.autor,
        livro.genero,
        livro.publicacao,
      ].join(' ').toLowerCase();

      final encontrouTexto = texto.contains(pesquisa);

      final encontrouFiltro =
          filtroSelecionado == 'Nenhum' ||
          livro.status.toLowerCase().trim() ==
              filtroSelecionado.toLowerCase();

      return encontrouTexto && encontrouFiltro;
    }).toList();
  }

  bool _livroDisponivel(Livro livro) {
    final status = livro.status.toLowerCase().trim();

    return status == 'livre' ||
        status == 'disponível' ||
        status == 'disponivel';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        backgroundColor: AppPalette.primary,
        title: const Text(
          'Biblioteca Virtual',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () =>
                  Scaffold.of(context).openEndDrawer(),
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      endDrawer: _menu(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: carregar,
          child: Column(
            children: [
              const SizedBox(height: 25),
              _barraPesquisa(),
              const SizedBox(height: 20),
              Expanded(
                child: _conteudo(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conteudo() {
    if (carregando) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (erro != null) {
      return _erroView();
    }

    final lista = livrosFiltrados;

    if (lista.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 80),
          Center(
            child: Text('Nenhum livro encontrado.'),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return _catalogoDesktop(lista);
        }

        return _catalogoMobile(lista);
      },
    );
  }

  Widget _erroView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        const Icon(
          Icons.cloud_off,
          size: 55,
          color: AppPalette.primary,
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            erro ?? 'Não foi possível carregar o catálogo.',
            textAlign: TextAlign.center,
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: carregar,
            child: const Text('Tentar novamente'),
          ),
        ),
      ],
    );
  }

  Widget _barraPesquisa() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: pesquisaController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Pesquise título, autor, ano...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppPalette.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    color: AppPalette.primary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    color: AppPalette.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _filtro(),
        ],
      ),
    );
  }

  Widget _filtro() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppPalette.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: filtroSelecionado,
          dropdownColor: Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
          ),
          style: const TextStyle(color: Colors.white),
          items: const [
            DropdownMenuItem(
              value: 'Nenhum',
              child: Text(
                'Nenhum',
                style: TextStyle(color: Colors.black),
              ),
            ),
            DropdownMenuItem(
              value: 'Livre',
              child: Text(
                'Livre',
                style: TextStyle(color: Colors.black),
              ),
            ),
            DropdownMenuItem(
              value: 'Emprestado',
              child: Text(
                'Emprestado',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
          onChanged: (valor) {
            setState(() {
              filtroSelecionado = valor ?? 'Nenhum';
            });
          },
        ),
      ),
    );
  }

  Widget _catalogoDesktop(List<Livro> lista) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(55, 5, 55, 30),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 28,
        mainAxisSpacing: 12,
        childAspectRatio: 2.7,
      ),
      itemCount: lista.length,
      itemBuilder: (_, index) => _livroCard(lista[index]),
    );
  }

  Widget _catalogoMobile(List<Livro> lista) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 25),
      itemCount: lista.length,
      itemBuilder: (_, index) => _livroCard(lista[index]),
    );
  }

  Widget _livroCard(Livro livro) {
    final disponivel = _livroDisponivel(livro);
    final id = livro.id;
    final enviando = id != null && solicitando.contains(id);

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 8,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF999999),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  livro.titulo,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  livro.descricao,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
                if (livro.autor.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    'Autor: ${livro.autor}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  livro.status,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: disponivel
                        ? AppPalette.green
                        : AppPalette.red,
                  ),
                ),
                if (disponivel) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: id == null || enviando
                          ? null
                          : () => _solicitarEmprestimo(livro),
                      icon: enviando
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.bookmark_add_outlined,
                              size: 18,
                            ),
                      label: Text(
                        enviando
                            ? 'Enviando...'
                            : 'Solicitar empréstimo',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 18),
          _capaLivro(livro.imagem),
        ],
      ),
    );
  }

  Widget _capaLivro(String caminho) {
    final isNetwork =
        caminho.startsWith('http://') ||
        caminho.startsWith('https://');

    final Widget imagem;

    if (isNetwork) {
      imagem = Image.network(
        caminho,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    } else {
      imagem = Image.asset(
        caminho.isEmpty
            ? 'assets/img/bibliosesi_mobile.jpeg'
            : caminho,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }

    return SizedBox(
      width: 102,
      height: 145,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: imagem,
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE2DCDC),
      child: const Center(
        child: Icon(
          Icons.menu_book,
          color: AppPalette.primary,
          size: 45,
        ),
      ),
    );
  }

  Widget _menu(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      backgroundColor: AppPalette.primary,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Icon(
              Icons.local_library,
              color: Colors.white,
              size: 65,
            ),
            const SizedBox(height: 10),
            const Text(
              'BiblioSesi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 35),
            _itemMenu(
              context,
              Icons.home,
              'Início',
              () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(
                  context,
                  '/home',
                );
              },
            ),
            _itemMenu(
              context,
              Icons.account_circle,
              'Perfil do Usuário',
              () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/perfil');
              },
            ),
            _itemMenu(
              context,
              Icons.folder,
              'Empréstimos',
              () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/emprestimos',
                );
              },
            ),
            _itemMenu(
              context,
              Icons.menu_book,
              'Catálogo',
              () => Navigator.pop(context),
            ),
            const Spacer(),
            _itemMenu(
              context,
              Icons.logout,
              'Sair',
              () {
                Session.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (_) => false,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _itemMenu(
    BuildContext context,
    IconData icone,
    String texto,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icone,
        color: Colors.white,
        size: 27,
      ),
      title: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

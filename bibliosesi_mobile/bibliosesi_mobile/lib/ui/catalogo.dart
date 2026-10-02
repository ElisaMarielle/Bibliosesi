import 'package:flutter/material.dart';

import '../root/pallet.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final TextEditingController pesquisaController =
      TextEditingController();

  String filtroSelecionado = 'Nenhum';

  final List<Livro> livros = [
    Livro(
      titulo: 'Moby Dick',
      descricao:
          'Moby Dick narra a obsessão do capitão Ahab em caçar a gigantesca baleia branca que lhe tirou a perna, mergulhando a tripulação do Pequod em uma jornada de vingança.',
      imagem: 'assets/img/mobyd.jpg',
      status: 'Emprestado',
    ),

    Livro(
      titulo: 'Divina Comédia',
      descricao:
          'Em Divina Comédia, Dante viaja pelos reinos do inferno, purgatório e paraíso, explorando a alma humana, a justiça divina e o caminho da redenção.',
      imagem: 'assets/img/divcom.jpg',
      status: 'Livre',
    ),

    Livro(
      titulo: 'Anne of Green Gables',
      descricao:
          'Anne of Green Gables conta a história de Anne Shirley, uma órfã sonhadora e cheia de imaginação que transforma a vida das pessoas ao seu redor.',
      imagem: 'assets/img/anneogg.jpg',
      status: 'Livre',
    ),

    Livro(
      titulo: 'Harry Potter e a Pedra Filosofal',
      descricao:
          'Harry Potter descobre que é um bruxo e começa seus estudos em Hogwarts, onde passa a viver grandes aventuras ao lado de seus amigos.',
      imagem: 'assets/img/hp.jpg',
      status: 'Emprestado',
    ),

    Livro(
      titulo: 'Orgulho e preconceito',
      descricao:
          'O romance acompanha Elizabeth Bennet e Sr. Darcy, que precisam superar orgulho, preconceitos e diferenças sociais.',
      imagem: 'assets/img/orgulho.jpg',
      status: 'Livre',
    ),

    Livro(
      titulo: 'Jogos vorazes',
      descricao:
          'Katniss Everdeen enfrenta os Jogos Vorazes e passa a representar uma resistência contra o sistema da Capital.',
      imagem: 'assets/img/jogos.jpg',
      status: 'Livre',
    ),
  ];

  @override
  void dispose() {
    pesquisaController.dispose();

    super.dispose();
  }

  List<Livro> get livrosFiltrados {
    final pesquisa =
        pesquisaController.text.toLowerCase().trim();

    return livros.where((livro) {
      final encontrouTexto =
          livro.titulo.toLowerCase().contains(pesquisa) ||
          livro.descricao.toLowerCase().contains(pesquisa);

      final encontrouFiltro =
          filtroSelecionado == 'Nenhum' ||
          livro.status == filtroSelecionado;

      return encontrouTexto && encontrouFiltro;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,

      appBar: AppBar(
        backgroundColor: AppPalette.primary,
        elevation: 0,

        leading: const Icon(
          Icons.menu_book,
          color: Colors.white,
        ),

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
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },

                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 30,
                ),
              );
            },
          ),
        ],
      ),

      endDrawer: _menu(context),

      body: Column(
        children: [
          const SizedBox(height: 25),

          _barraPesquisa(),

          const SizedBox(height: 20),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 800) {
                  return _catalogoDesktop();
                }

                return _catalogoMobile();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _barraPesquisa() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: pesquisaController,

              onChanged: (_) {
                setState(() {});
              },

              decoration: InputDecoration(
                hintText:
                    'Pesquise o título, autor, ano, etc...',

                prefixIcon: const Icon(
                  Icons.search,
                  color: AppPalette.primary,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(25),

                  borderSide: const BorderSide(
                    color: AppPalette.primary,
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(25),

                  borderSide: const BorderSide(
                    color: AppPalette.primary,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(25),

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

      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),

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

          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'serif',
          ),

          items: const [
            DropdownMenuItem(
              value: 'Nenhum',
              child: Text('Nenhum'),
            ),

            DropdownMenuItem(
              value: 'Livre',
              child: Text('Livre'),
            ),

            DropdownMenuItem(
              value: 'Emprestado',
              child: Text('Emprestado'),
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
    );
  }

  Widget _catalogoDesktop() {
    final lista = livrosFiltrados;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        55,
        5,
        55,
        30,
      ),

      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 28,
        mainAxisSpacing: 0,
        childAspectRatio: 2.7,
      ),

      itemCount: lista.length,

      itemBuilder: (context, index) {
        return _livroCard(lista[index]);
      },
    );
  }

  Widget _catalogoMobile() {
    final lista = livrosFiltrados;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        5,
        16,
        25,
      ),

      itemCount: lista.length,

      itemBuilder: (context, index) {
        return _livroCard(lista[index]);
      },
    );
  }

  Widget _livroCard(Livro livro) {
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
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

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

                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  livro.status,

                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,

                    color: livro.status ==
                            'Emprestado'
                        ? AppPalette.red
                        : AppPalette.green,
                  ),
                ),
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
    return SizedBox(
      width: 102,
      height: 145,

      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),

        child: Image.asset(
          caminho,

          fit: BoxFit.cover,

          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
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
          },
        ),
      ),
    );
  }

  Widget _menu(BuildContext context) {
    return Drawer(
      width:
          MediaQuery.of(context).size.width * 0.82,

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
                fontFamily: 'serif',
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

                Navigator.pushNamed(
                  context,
                  '/perfil',
                );
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
              () {
                Navigator.pop(context);
              },
            ),

            const Spacer(),

            _itemMenu(
              context,
              Icons.logout,
              'Sair',
              () {
                Navigator.pushReplacementNamed(
                  context,
                  '/login',
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
          fontFamily: 'serif',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class Livro {
  final String titulo;
  final String descricao;
  final String imagem;
  final String status;

  Livro({
    required this.titulo,
    required this.descricao,
    required this.imagem,
    required this.status,
  });
}
import 'package:flutter/material.dart';

import '../root/pallet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,

      appBar: AppBar(
        backgroundColor: AppPalette.primary,

        leading: const Icon(
          Icons.menu_book,
          color: Colors.white,
        ),

        title: const Text(
          'Biblioteca Virtual',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.normal,
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
                ),
              );
            },
          ),
        ],
      ),

      endDrawer: _menu(context),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Bem-vindo à BiblioSesi',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Encontre livros, consulte seus empréstimos e acompanhe suas reservas.',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Principais Notícias da Semana',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _noticia(
              'Mês do livro: Veja 7 caminhos para formar leitores na era digital.',
              'Educadores apontam estratégias práticas para estimular a leitura de crianças e adolecentes em meio à disputa com as telas',
              'assets/img/leitura-era-digital.webp',
            ),

            _noticia(
              '15 escritoras brasileiras para conhecer e ler em 2026',
              'Neste Dia Internacional da Mulher conheça autoras brasileiras que podem fazer parte da sua próxima leitura.',
              'assets/img/escritoras.jpg',
            ),

            _noticia(
              'Prêmio contempla duas categorias: Escritores regionais e Jovens Escritores (para estudantes do 6 ao 9 ano)',
              'Prêmio celebra diversidade cultural e formação de leitores-escritores.',
              'assets/img/bibliosesi_mobile.jpeg',
            ),

            _noticia(
              'Livros gratuitos em aplicativo do MEC? Saiba como utilizar a plataforma',
              'Com tecnologia que mescla títulos de domínio público e lançamentos de mercado, MEC Livros reúne um catálogo de quase 8 mil obras literárias.',
              'assets/img/livros-mec-livros.jpg',
            ),
          ],
        ),
      ),
    );
  }

  Widget _noticia(
    String titulo,
    String descricao,
    String imagem,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(10),

        border: Border.all(
          color: const Color(0xFFE1D6D6),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(10),
            ),

            child: SizedBox(
              width: double.infinity,
              height: 180,

              child: Image.asset(
                imagem,
                fit: BoxFit.cover,

                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Container(
                    color: const Color(0xFFE8DDDD),

                    child: const Icon(
                      Icons.image,
                      size: 50,
                      color: AppPalette.primary,
                    ),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  descricao,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
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

                Navigator.pushNamed(
                  context,
                  '/catalogo',
                );
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
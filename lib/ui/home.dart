import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../root/pallet.dart';
import '../models/models.dart';
import 'login.dart';
=======
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const corHome = Color(0xFF902222);
const fundoHome = Color(0xFF121212);
const cartaoHome = Color(0xFF1E1E1E);
const textoSecundarioHome = Color(0xFFBDBDBD);
>>>>>>> e1baffa (Atualiza telas e funcionalidades do aplicativo)

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Noticia> noticias = [];
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    setState(() { carregando = true; erro = null; });
    try {
      final lista = await Session.api.listarNoticias();
      if (!mounted) return;
      setState(() => noticias = lista);
    } catch (e) {
      if (!mounted) return;
      setState(() => erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> sair(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('usuario');

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  Future<void> abrirNoticia(
    BuildContext context,
    String endereco,
  ) async {
    final uri = Uri.parse(endereco);

    try {
      final abriu = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!abriu && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir a notícia.'),
            backgroundColor: corHome,
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao abrir o link da notícia.'),
          backgroundColor: corHome,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        backgroundColor: AppPalette.primary,
        leading: const Icon(Icons.menu_book, color: Colors.white),
        title: const Text('Biblioteca Virtual', style: TextStyle(color: Colors.white, fontSize: 17)),
        centerTitle: true,
        actions: [Builder(builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openEndDrawer(),
          icon: const Icon(Icons.menu, color: Colors.white),
        ))],
      ),
      endDrawer: _menu(context),
      body: RefreshIndicator(
        onRefresh: carregar,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Bem-vindo à BiblioSesi', style: TextStyle(fontFamily: 'serif', fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              Session.usuario == null ? 'Encontre livros, consulte seus empréstimos e acompanhe suas reservas.' : 'Olá, ${Session.usuario!.nome}!',
              style: const TextStyle(fontFamily: 'serif', fontSize: 15),
            ),
            const SizedBox(height: 30),
            const Text('Principais Notícias da Semana', style: TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (carregando) const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
            if (!carregando && erro != null) ...[
              Center(child: Text(erro!, textAlign: TextAlign.center)),
              Center(child: ElevatedButton(onPressed: carregar, child: const Text('Tentar novamente'))),
            ],
            if (!carregando && erro == null && noticias.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('Nenhuma notícia cadastrada.'))),
            ...noticias.map(_noticia),
          ]),
=======
      backgroundColor: fundoHome,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(
          Icons.menu_book_rounded,
          color: Colors.white,
          size: 27,
        ),
        title: const Text(
          'BiblioSesi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                tooltip: 'Abrir menu',
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
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cartaoHome,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF363636)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: corHome,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Bem-vindo à BiblioSesi',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Encontre sua próxima leitura, consulte seus empréstimos e acompanhe suas reservas.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: textoSecundarioHome,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 47,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/catalogo');
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Explorar catálogo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: corHome,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Row(
              children: [
                Icon(
                  Icons.newspaper_rounded,
                  color: Colors.white,
                  size: 23,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Notícias da semana',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            const Text(
              'Novidades sobre livros, leitura e literatura.',
              style: TextStyle(
                fontSize: 13,
                color: textoSecundarioHome,
              ),
            ),
            const SizedBox(height: 20),

            _noticia(
              context,
              'Mês do livro: veja 7 caminhos para formar leitores na era digital',
              'Educadores apontam estratégias práticas para estimular a leitura de crianças e adolescentes em meio à disputa com as telas.',
              'assets/img/leitura-era-digital.webp',
              'https://www.cnnbrasil.com.br/educacao/mes-do-livro-veja-7-caminhos-para-formar-leitores-na-era-digital/',
            ),

            _noticia(
              context,
              '15 escritoras brasileiras para conhecer e ler em 2026',
              'Conheça autoras brasileiras de diferentes gêneros e descubra novas possibilidades para sua próxima leitura.',
              'assets/img/escritoras.jpg',
              'https://www.metropoles.com/entretenimento/literatura/15-escritoras-brasileiras-para-conhecer-e-ler-em-2026',
            ),

            _noticia(
              context,
              'Prêmio contempla escritores regionais e jovens escritores',
              'Conheça o Prêmio Multiverso de Literatura, que valoriza a produção literária regional e incentiva novos talentos.',
              'assets/img/bibliosesi_mobile.jpeg',
              'https://premiomultiverso.com.br/',
            ),

            _noticia(
              context,
              'Livros gratuitos em aplicativo do MEC? Saiba como utilizar a plataforma',
              'Conheça a plataforma MEC Livros e saiba como acessar seu catálogo de obras literárias.',
              'assets/img/livros-mec-livros.jpg',
              'https://www.cnnbrasil.com.br/educacao/livros-gratuitos-em-aplicativo-do-mec-saiba-como-utilizar-a-plataforma/',
            ),
          ],
>>>>>>> e1baffa (Atualiza telas e funcionalidades do aplicativo)
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _noticia(Noticia noticia) => Container(
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE1D6D6))),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(noticia.titulo, style: const TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(noticia.conteudo, style: const TextStyle(fontFamily: 'serif', fontSize: 14)),
        if (noticia.autor.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('Por ${noticia.autor}', style: const TextStyle(fontSize: 12)),
=======
  Widget _noticia(
    BuildContext context,
    String titulo,
    String descricao,
    String imagem,
    String endereco,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: cartaoHome,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF363636)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 185,
            child: Image.asset(
              imagem,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF292929),
                  child: const Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 55,
                      color: Colors.white54,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: corHome,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'LITERATURA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  descricao,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: textoSecundarioHome,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      abrirNoticia(context, endereco);
                    },
                    icon: const Icon(
                      Icons.open_in_new,
                      size: 18,
                    ),
                    label: const Text('Veja a matéria completa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: corHome),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
>>>>>>> e1baffa (Atualiza telas e funcionalidades do aplicativo)
        ],
      ]),
    ),
  );

<<<<<<< HEAD
  Widget _menu(BuildContext context) => Drawer(
    width: MediaQuery.of(context).size.width * 0.82,
    backgroundColor: AppPalette.primary,
    child: SafeArea(child: Column(children: [
      const SizedBox(height: 30),
      const Icon(Icons.local_library, color: Colors.white, size: 65),
      const SizedBox(height: 10),
      const Text('BiblioSesi', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold)),
      const SizedBox(height: 35),
      _itemMenu(context, Icons.home, 'Início', () => Navigator.pop(context)),
      _itemMenu(context, Icons.account_circle, 'Perfil do Usuário', () { Navigator.pop(context); Navigator.pushNamed(context, '/perfil'); }),
      _itemMenu(context, Icons.folder, 'Empréstimos', () { Navigator.pop(context); Navigator.pushNamed(context, '/emprestimos'); }),
      _itemMenu(context, Icons.menu_book, 'Catálogo', () { Navigator.pop(context); Navigator.pushNamed(context, '/catalogo'); }),
      const Spacer(),
      _itemMenu(context, Icons.logout, 'Sair', () { Session.logout(); Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false); }),
      const SizedBox(height: 20),
    ])),
  );

  Widget _itemMenu(BuildContext context, IconData icone, String texto, VoidCallback onTap) => ListTile(
    onTap: onTap,
    leading: Icon(icone, color: Colors.white),
    title: Text(texto, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
  );
}
=======
  Widget _menu(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      backgroundColor: cartaoHome,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 28),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: corHome,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.local_library_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 13),
            const Text(
              'BiblioSesi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Sua biblioteca digital',
              style: TextStyle(
                color: textoSecundarioHome,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 25),
            const Divider(
              color: Color(0xFF363636),
              indent: 20,
              endIndent: 20,
            ),
            const SizedBox(height: 10),
            _itemMenu(
              context,
              Icons.home_outlined,
              'Início',
              () => Navigator.pop(context),
            ),
            _itemMenu(
              context,
              Icons.person_outline,
              'Perfil do usuário',
              () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/perfil');
              },
            ),
            _itemMenu(
              context,
              Icons.bookmark_border,
              'Empréstimos',
              () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/emprestimos');
              },
            ),
            _itemMenu(
              context,
              Icons.menu_book_outlined,
              'Catálogo',
              () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/catalogo');
              },
            ),
            const Spacer(),
            const Divider(
              color: Color(0xFF363636),
              indent: 20,
              endIndent: 20,
            ),
            _itemMenu(
              context,
              Icons.logout,
              'Sair da conta',
              () => sair(context),
            ),
            const SizedBox(height: 15),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: onTap,
      leading: Icon(
        icone,
        color: Colors.white70,
        size: 23,
      ),
      title: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white38,
        size: 20,
      ),
    );
  }
}
>>>>>>> e1baffa (Atualiza telas e funcionalidades do aplicativo)

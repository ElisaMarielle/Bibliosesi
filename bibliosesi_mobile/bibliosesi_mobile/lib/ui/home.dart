import 'package:flutter/material.dart';
import '../root/pallet.dart';
import '../models/models.dart';
import 'login.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ),
      ),
    );
  }

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
        ],
      ]),
    ),
  );

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

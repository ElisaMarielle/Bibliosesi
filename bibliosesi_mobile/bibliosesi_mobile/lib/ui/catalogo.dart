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
  final pesquisaController = TextEditingController();
  String filtroSelecionado = 'Nenhum';
  List<Livro> livros = [];
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
      final lista = await Session.api.listarLivros();
      if (!mounted) return;
      setState(() => livros = lista);
    } catch (e) {
      if (!mounted) return;
      setState(() => erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  List<Livro> get livrosFiltrados {
    final pesquisa = pesquisaController.text.toLowerCase().trim();
    return livros.where((livro) {
      final texto = '${livro.titulo} ${livro.descricao} ${livro.autor} ${livro.genero} ${livro.publicacao}'.toLowerCase();
      final encontrouTexto = texto.contains(pesquisa);
      final encontrouFiltro = filtroSelecionado == 'Nenhum' || livro.status == filtroSelecionado;
      return encontrouTexto && encontrouFiltro;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        backgroundColor: AppPalette.primary,
        title: const Text('Biblioteca Virtual', style: TextStyle(color: Colors.white, fontSize: 17)),
        centerTitle: true,
        actions: [
          Builder(builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
          )),
        ],
      ),
      endDrawer: _menu(context),
      body: RefreshIndicator(
        onRefresh: carregar,
        child: Column(
          children: [
            const SizedBox(height: 25),
            _barraPesquisa(),
            const SizedBox(height: 20),
            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : erro != null
                      ? _erroView()
                      : livrosFiltrados.isEmpty
                          ? const Center(child: Text('Nenhum livro encontrado.'))
                          : LayoutBuilder(builder: (context, constraints) {
                              if (constraints.maxWidth >= 800) return _catalogoDesktop();
                              return _catalogoMobile();
                            }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _erroView() => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      const SizedBox(height: 80),
      const Icon(Icons.cloud_off, size: 55, color: AppPalette.primary),
      const SizedBox(height: 15),
      Center(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(erro ?? 'Não foi possível carregar o catálogo.', textAlign: TextAlign.center),
      )),
      Center(child: ElevatedButton(onPressed: carregar, child: const Text('Tentar novamente'))),
    ],
  );

  Widget _barraPesquisa() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(children: [
      Expanded(child: TextField(
        controller: pesquisaController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Pesquise título, autor, ano...',
          prefixIcon: const Icon(Icons.search, color: AppPalette.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: AppPalette.primary)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: AppPalette.primary, width: 1.5)),
        ),
      )),
      const SizedBox(width: 12),
      _filtro(),
    ]),
  );

  Widget _filtro() => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: AppPalette.primary, borderRadius: BorderRadius.circular(25)),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: filtroSelecionado,
        dropdownColor: Colors.white,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        style: const TextStyle(color: Colors.white),
        items: const [
          DropdownMenuItem(value: 'Nenhum', child: Text('Nenhum')),
          DropdownMenuItem(value: 'Livre', child: Text('Livre')),
          DropdownMenuItem(value: 'Emprestado', child: Text('Emprestado')),
        ],
        onChanged: (valor) => setState(() => filtroSelecionado = valor ?? 'Nenhum'),
      ),
    ),
  );

  Widget _catalogoDesktop() => GridView.builder(
    padding: const EdgeInsets.fromLTRB(55, 5, 55, 30),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 28, childAspectRatio: 2.7),
    itemCount: livrosFiltrados.length,
    itemBuilder: (_, index) => _livroCard(livrosFiltrados[index]),
  );

  Widget _catalogoMobile() => ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 5, 16, 25),
    itemCount: livrosFiltrados.length,
    itemBuilder: (_, index) => _livroCard(livrosFiltrados[index]),
  );

  Widget _livroCard(Livro livro) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF999999), width: 0.8))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(livro.titulo, style: const TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(livro.descricao, maxLines: 6, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'serif', fontSize: 13, height: 1.25)),
        if (livro.autor.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text('Autor: ${livro.autor}', style: const TextStyle(fontSize: 12)),
        ],
        const SizedBox(height: 12),
        Text(livro.status, style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.bold,
          color: livro.status.toLowerCase().contains('emprest') ? AppPalette.red : AppPalette.green,
        )),
      ])),
      const SizedBox(width: 18),
      _capaLivro(livro.imagem),
    ]),
  );

  Widget _capaLivro(String caminho) {
    final isNetwork = caminho.startsWith('http://') || caminho.startsWith('https://');
    final image = isNetwork
        ? Image.network(caminho, fit: BoxFit.cover, errorBuilder: (_,_,_) => _placeholder())
        : Image.asset(caminho.isEmpty ? 'assets/img/bibliosesi_mobile.jpeg' : caminho, fit: BoxFit.cover, errorBuilder: (_, _, _) => _placeholder());
    return SizedBox(width: 102, height: 145, child: ClipRRect(borderRadius: BorderRadius.circular(7), child: image));
  }

  Widget _placeholder() => Container(
    color: const Color(0xFFE2DCDC),
    child: const Center(child: Icon(Icons.menu_book, color: AppPalette.primary, size: 45)),
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
      _itemMenu(context, Icons.home, 'Início', () { Navigator.pop(context); Navigator.pushReplacementNamed(context, '/home'); }),
      _itemMenu(context, Icons.account_circle, 'Perfil do Usuário', () { Navigator.pop(context); Navigator.pushNamed(context, '/perfil'); }),
      _itemMenu(context, Icons.folder, 'Empréstimos', () { Navigator.pop(context); Navigator.pushNamed(context, '/emprestimos'); }),
      _itemMenu(context, Icons.menu_book, 'Catálogo', () => Navigator.pop(context)),
      const Spacer(),
      _itemMenu(context, Icons.logout, 'Sair', () { Session.logout(); Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false); }),
      const SizedBox(height: 20),
    ])),
  );

  Widget _itemMenu(BuildContext context, IconData icone, String texto, VoidCallback onTap) => ListTile(
    onTap: onTap,
    leading: Icon(icone, color: Colors.white, size: 27),
    title: Text(texto, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
  );
}

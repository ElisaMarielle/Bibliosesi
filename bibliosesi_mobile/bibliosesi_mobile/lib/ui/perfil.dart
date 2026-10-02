import 'package:flutter/material.dart';
import '../root/pallet.dart';
import '../models/models.dart';
import 'login.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});
  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  List<Emprestimo> emprestimos = [];
  List<FilaItem> reservas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    try {
      final results = await Future.wait([
        Session.api.listarEmprestimos(),
        Session.api.listarFila(),
      ]);
      if (!mounted) return;
      setState(() {
        emprestimos = results[0] as List<Emprestimo>;
        reservas = results[1] as List<FilaItem>;
      });
    } catch (_) {
      // O perfil continua mostrando os dados básicos mesmo se as estatísticas falharem.
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = Session.usuario;
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(title: const Text('Perfil', style: TextStyle(fontFamily: 'serif')), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _perfil(usuario),
          const SizedBox(height: 20),
          _estatisticas(),
          const SizedBox(height: 25),
          if (reservas.isNotEmpty) _reserva(reservas.first),
        ]),
      ),
    );
  }

  Widget _perfil(Usuario? usuario) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      const CircleAvatar(radius: 50, backgroundColor: AppPalette.primary, child: Icon(Icons.person, color: Colors.white, size: 55)),
      const SizedBox(height: 12),
      Text(usuario?.nome.isNotEmpty == true ? usuario!.nome : 'Usuário', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'serif', fontSize: 21, fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      Text(usuario?.rm == null ? 'RM não informado' : 'RM: ${usuario!.rm}', style: const TextStyle(fontFamily: 'serif')),
      Text(usuario?.email ?? '', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'serif')),
    ]),
  );

  Widget _estatisticas() => Row(children: [
    Expanded(child: _numero(reservas.length.toString(), 'Reservas')),
    const SizedBox(width: 10),
    Expanded(child: _numero(emprestimos.length.toString(), 'Livros emprestados')),
    const SizedBox(width: 10),
    Expanded(child: _numero(
      emprestimos.where((e) => e.status.toLowerCase().contains('posse')).length.toString(),
      'Livros em posse',
    )),
  ]);

  Widget _numero(String numero, String texto) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: AppPalette.primary, borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Text(numero, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      Text(texto, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12)),
    ]),
  );

  Widget _reserva(FilaItem item) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppPalette.primary, borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Minha reserva', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text(item.tituloLivro.isEmpty ? 'Livro #${item.livroId ?? '-'}' : item.tituloLivro, style: const TextStyle(color: Colors.white)),
      const SizedBox(height: 5),
      Text('${item.posicao ?? '-'}º lugar na fila', style: const TextStyle(color: Colors.white)),
    ]),
  );
}
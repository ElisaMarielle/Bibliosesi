import 'package:flutter/material.dart';
import '../root/pallet.dart';
import '../models/models.dart';
import 'login.dart';

class EmprestimosPage extends StatefulWidget {
  const EmprestimosPage({super.key});
  @override
  State<EmprestimosPage> createState() => _EmprestimosPageState();
}

class _EmprestimosPageState extends State<EmprestimosPage> {
  List<Emprestimo> emprestimos = [];
  List<FilaItem> fila = [];
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
      final results = await Future.wait([
        Session.api.listarEmprestimos(),
        Session.api.listarFila(),
      ]);
      if (!mounted) return;
      setState(() {
        emprestimos = results[0] as List<Emprestimo>;
        fila = results[1] as List<FilaItem>;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> cancelarReserva(FilaItem item) async {
    if (item.id == null) return;
    try {
      await Session.api.cancelarReserva(item.id!);
      await carregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  String _data(String value) {
    if (value.isEmpty) return 'Data não informada';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(title: const Text('Empréstimos', style: TextStyle(fontFamily: 'serif')), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: carregar,
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : erro != null
                ? ListView(children: [const SizedBox(height: 80), Center(child: Padding(padding: EdgeInsets.all(20), child: Text(erro!, textAlign: TextAlign.center))), Center(child: ElevatedButton(onPressed: carregar, child: const Text('Tentar novamente')))])
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text('Meus empréstimos', style: TextStyle(fontFamily: 'serif', fontSize: 25, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      if (emprestimos.isEmpty) const Text('Você não possui empréstimos no momento.'),
                      ...emprestimos.map((e) => _livroEmprestado(e)),
                      const SizedBox(height: 30),
                      const Text('Reservas', style: TextStyle(fontFamily: 'serif', fontSize: 25, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      if (fila.isEmpty) const Text('Você não possui reservas na fila.'),
                      ...fila.map(_reserva),
                    ],
                  ),
      ),
    );
  }

  Widget _livroEmprestado(Emprestimo item) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE0D4D4))),
    child: Row(children: [
      const Icon(Icons.menu_book, color: AppPalette.primary, size: 45),
      const SizedBox(width: 15),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.tituloLivro.isEmpty ? 'Livro #${item.livroId ?? '-'}' : item.tituloLivro, style: const TextStyle(fontFamily: 'serif', fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Devolução: ${_data(item.dataDevolucao)}'),
        const SizedBox(height: 5),
        Text(item.status, style: const TextStyle(color: AppPalette.green, fontWeight: FontWeight.bold)),
      ])),
    ]),
  );

  Widget _reserva(FilaItem item) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppPalette.primary, borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(item.tituloLivro.isEmpty ? 'Livro #${item.livroId ?? '-'}' : item.tituloLivro, style: const TextStyle(color: Colors.white, fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text('${item.posicao ?? '-'}º lugar na fila', style: const TextStyle(color: Colors.white)),
      const SizedBox(height: 15),
      OutlinedButton(
        onPressed: item.id == null ? null : () => cancelarReserva(item),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
        child: const Text('Cancelar reserva'),
      ),
    ]),
  );
}

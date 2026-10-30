
import 'package:flutter/material.dart';

const corPrincipal = Color(0xFF902222);
const corFundo = Color(0xFF121212);
const corCartao = Color(0xFF1E1E1E);
const corTextoSecundario = Color(0xFFBDBDBD);

class EmprestimosPage extends StatefulWidget {
  const EmprestimosPage({super.key});

  @override
  State<EmprestimosPage> createState() => _EmprestimosPageState();
}

class _EmprestimosPageState extends State<EmprestimosPage> {
  bool reservaAtiva = true;

  Future<void> cancelarReserva() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: corCartao,
          title: const Text(
            'Cancelar reserva?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Deseja realmente cancelar a reserva de Sociedade do Cansaço?',
            style: TextStyle(color: corTextoSecundario),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Voltar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: corPrincipal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O cancelamento ainda precisa ser conectado ao backend.',
          ),
          backgroundColor: corPrincipal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Empréstimos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meus empréstimos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Acompanhe os livros que estão com você.',
              style: TextStyle(
                color: corTextoSecundario,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            _livroEmprestado(
              titulo: 'O Pequeno Príncipe',
              data: 'Entrega: 20/05/2026',
              status: 'Em posse',
            ),
            _livroEmprestado(
              titulo: 'Naruto vol. 2',
              data: 'Entrega: 25/05/2026',
              status: 'Em posse',
            ),
            const SizedBox(height: 18),
            const Divider(color: Color(0xFF363636)),
            const SizedBox(height: 18),
            const Text(
              'Minhas reservas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Confira sua posição na fila de reservas.',
              style: TextStyle(
                color: corTextoSecundario,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            if (reservaAtiva)
              _reserva()
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: corCartao,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF363636)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      color: Colors.white54,
                      size: 42,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Nenhuma reserva ativa.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _livroEmprestado({
    required String titulo,
    required String data,
    required String status,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: corCartao,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF363636)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 72,
            decoration: BoxDecoration(
              color: corPrincipal,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: corTextoSecundario,
                      size: 17,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        data,
                        style: const TextStyle(
                          color: corTextoSecundario,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      color: Color(0xFF81C784),
                      size: 10,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      status,
                      style: const TextStyle(
                        color: Color(0xFF81C784),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reserva() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: corCartao,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: corPrincipal,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 58,
                decoration: BoxDecoration(
                  color: corPrincipal,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bookmark_added_outlined,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sociedade do Cansaço',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Reserva ativa',
                      style: TextStyle(
                        color: Color(0xFF81C784),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF292929),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.format_list_numbered,
                  color: Colors.white70,
                  size: 22,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '2º lugar na fila',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: corTextoSecundario,
                size: 19,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Previsão de entrega: 22/05/2026',
                  style: TextStyle(
                    color: corTextoSecundario,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: cancelarReserva,
              icon: const Icon(Icons.close),
              label: const Text('Cancelar reserva'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: corPrincipal),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

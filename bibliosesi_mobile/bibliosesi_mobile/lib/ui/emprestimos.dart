import 'package:flutter/material.dart';

import '../root/pallet.dart';

class EmprestimosPage extends StatelessWidget {
  const EmprestimosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,

      appBar: AppBar(
        title: const Text(
          'Empréstimos',
          style: TextStyle(
            fontFamily: 'serif',
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              'Meus empréstimos',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _livroEmprestado(
              'O Pequeno Príncipe',
              'Entrega: 20/05/2026',
              'Em posse',
            ),

            _livroEmprestado(
              'Naruto vol. 2',
              'Entrega: 25/05/2026',
              'Em posse',
            ),

            const SizedBox(height: 30),

            const Text(
              'Reservas',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _reserva(),
          ],
        ),
      ),
    );
  }

  Widget _livroEmprestado(
    String titulo,
    String data,
    String status,
  ) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(
        bottom: 15,
      ),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color: const Color(0xFFE0D4D4),
        ),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.menu_book,
            color: AppPalette.primary,
            size: 45,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  titulo,

                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  data,

                  style: const TextStyle(
                    fontFamily: 'serif',
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  status,

                  style: const TextStyle(
                    color: AppPalette.green,
                    fontWeight: FontWeight.bold,
                  ),
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
        color: AppPalette.primary,

        borderRadius:
            BorderRadius.circular(10),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Sociedade do Cansaço',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'serif',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            '2º lugar na fila',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'serif',
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Previsão de entrega: 22/05/2026',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'serif',
            ),
          ),

          const SizedBox(height: 15),

          OutlinedButton(
            onPressed: () {},

            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,

              side: const BorderSide(
                color: Colors.white,
              ),
            ),

            child: const Text(
              'Cancelar reserva',
            ),
          ),
        ],
      ),
    );
  }
}
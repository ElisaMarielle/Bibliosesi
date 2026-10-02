import 'package:flutter/material.dart';

import '../root/pallet.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,

      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(
            fontFamily: 'serif',
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            _perfil(),

            const SizedBox(height: 20),

            _estatisticas(),

            const SizedBox(height: 25),

            _reserva(),

            const SizedBox(height: 25),

            _avisos(),
          ],
        ),
      ),
    );
  }

  Widget _perfil() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(10),
      ),

      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,

            backgroundColor:
                AppPalette.primary,

            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 55,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Gabriela Caroline da Silva',
            textAlign: TextAlign.center,

            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            '3°A EM',
            style: TextStyle(
              fontFamily: 'serif',
            ),
          ),

          const Text(
            '1234',
            style: TextStyle(
              fontFamily: 'serif',
            ),
          ),

          const Text(
            'email.email@portalsesisp.org.br',
            textAlign: TextAlign.center,

            style: TextStyle(
              fontFamily: 'serif',
            ),
          ),

          const SizedBox(height: 15),

          OutlinedButton(
            onPressed: () {},

            child: const Text(
              'Editar foto',
            ),
          ),
        ],
      ),
    );
  }

  Widget _estatisticas() {
    return Row(
      children: [
        Expanded(
          child: _numero(
            '12',
            'Livros favoritos',
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _numero(
            '6',
            'Livros emprestados',
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _numero(
            '3',
            'Livros em posse',
          ),
        ),
      ],
    );
  }

  Widget _numero(
    String numero,
    String texto,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: AppPalette.primary,

        borderRadius:
            BorderRadius.circular(10),
      ),

      child: Column(
        children: [
          Text(
            numero,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            texto,
            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'serif',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reserva() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

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
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            '2º lugar',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'serif',
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Entrega prevista: 22/05/2026',
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

  Widget _avisos() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(10),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: AppPalette.primary,
              ),

              SizedBox(width: 8),

              Text(
                'Avisos',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Text(
            '• O livro "Crepúsculo" está perto do vencimento (1 dia).',
            style: TextStyle(
              fontFamily: 'serif',
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            '• O livro "Naruto vol. 2" está perto do vencimento (5 dias).',
            style: TextStyle(
              fontFamily: 'serif',
            ),
          ),
        ],
      ),
    );
  }
}
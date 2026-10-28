import 'package:flutter/material.dart';

import '../root/pallet.dart';
import '../root/sessao.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _abrirAplicativo();
  }

  Future<void> _abrirAplicativo() async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    final destino = Sessao.autenticado ? '/home' : '/login';

    Navigator.pushReplacementNamed(context, destino);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_library,
              size: 85,
              color: AppPalette.primary,
            ),
            const SizedBox(height: 18),
            Text(
              'BiblioSesi',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppPalette.white,
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              color: AppPalette.primary,
            ),
          ],
        ),
      ),
    );
  }
}
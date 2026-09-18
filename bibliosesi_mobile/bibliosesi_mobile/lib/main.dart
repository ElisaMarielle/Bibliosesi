import 'package:flutter/material.dart';

import 'root/theme.dart';
import 'ui/splash.dart';
import 'ui/login.dart';
import 'ui/home.dart';
import 'ui/catalogo.dart';
import 'ui/emprestimos.dart';
import 'ui/perfil.dart';

void main() {
  runApp(const BiblioSesiApp());
}

class BiblioSesiApp extends StatelessWidget {
  const BiblioSesiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'BiblioSesi',

      theme: AppTheme.lightTheme,

      home: const SplashPage(),

      routes: {

        '/login': (context) => const LoginPage(),
        
        '/home': (context) => const HomePage(),

        '/catalogo': (context) => const CatalogoPage(),

        '/emprestimos': (context) => const EmprestimosPage(),

        '/perfil': (context) => const PerfilPage(),
      },
    );
  }
}
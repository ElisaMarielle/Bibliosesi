import 'package:flutter/material.dart';

import 'root/pallet.dart';
import 'root/sessao.dart';

import 'ui/splash.dart';
import 'ui/login.dart';
import 'ui/cadastro_usuario.dart';
import 'ui/home.dart';
import 'ui/catalogo.dart';
import 'ui/emprestimos.dart';
import 'ui/perfil.dart';
import 'ui/cadastro.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Sessao.carregar();

  runApp(BiblioSesiApp());
}

class BiblioSesiApp extends StatelessWidget {
  const BiblioSesiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiblioSesi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppPalette.background,
        primaryColor: AppPalette.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppPalette.primary,
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppPalette.background,
          foregroundColor: AppPalette.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          labelStyle: TextStyle(color: AppPalette.gray),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppPalette.gray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppPalette.primary, width: 2),
          ),
        ),
      ),
      home: SplashPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/cadastro-usuario': (context) => CadastroUsuarioPage(),
        '/home': (context) => HomePage(),
        '/catalogo': (context) => CatalogoPage(),
        '/emprestimos': (context) => EmprestimosPage(),
        '/perfil': (context) => PerfilPage(),
        '/cadastro': (context) => CadastroLivro(),
        '/cadastro-livro': (context) => CadastroLivro(),
      },
    );
  }
}
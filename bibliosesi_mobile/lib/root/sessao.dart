import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Sessao {
  static String? token;
  static Map<String, dynamic>? usuario;

  static bool get autenticado =>
      token != null &&
      token!.isNotEmpty &&
      usuario != null;

  static Future<void> carregar() async {
    final preferencias = await SharedPreferences.getInstance();

    token = preferencias.getString('token');

    final usuarioSalvo = preferencias.getString('usuario');

    if (usuarioSalvo != null) {
      try {
        final dados = jsonDecode(usuarioSalvo);

        if (dados is Map) {
          usuario = Map<String, dynamic>.from(dados);
        }
      } catch (_) {
        usuario = null;
      }
    }
  }

  static Future<void> iniciar({
    required String novoToken,
    required Map<String, dynamic> novoUsuario,
  }) async {
    final preferencias = await SharedPreferences.getInstance();

    token = novoToken;
    usuario = Map<String, dynamic>.from(novoUsuario);

    await preferencias.setString('token', novoToken);
    await preferencias.setString(
      'usuario',
      jsonEncode(usuario),
    );
  }

  static Future<void> atualizarUsuario(
    Map<String, dynamic> novosDados,
  ) async {
    final preferencias = await SharedPreferences.getInstance();

    usuario = Map<String, dynamic>.from(novosDados);

    await preferencias.setString(
      'usuario',
      jsonEncode(usuario),
    );
  }

  static Future<void> limpar() async {
    final preferencias = await SharedPreferences.getInstance();

    token = null;
    usuario = null;

    await preferencias.remove('token');
    await preferencias.remove('usuario');
  }
}
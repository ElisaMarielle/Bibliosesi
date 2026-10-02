import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiConfig {

  static const String baseUrl = 'https://bibliosesi.vercel.app';
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  String? token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null && token!.isNotEmpty)
          'Authorization': 'Bearer $token',
      };

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  dynamic _decode(http.Response response) {
    dynamic body;
    try {
      body = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      body = response.body;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Erro ${response.statusCode} na API.';
      if (body is Map) {
        message = (body['message'] ?? body['erro'] ?? body['error'] ?? message).toString();
      }
      throw ApiException(message, response.statusCode);
    }
    return body;
  }

  List<dynamic> _asList(dynamic body, [List<String> keys = const []]) {
    if (body is List) return body;
    if (body is Map) {
      for (final key in keys) {
        if (body[key] is List) return body[key] as List;
      }
      for (final value in body.values) {
        if (value is List) return value;
      }
    }
    return [];
  }

  Future<Usuario> login(String email, String senha) async {
    final response = await http.post(
      _uri('/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'senha': senha}),
    );
    final body = _decode(response);

    if (body is! Map) {
      throw ApiException('Nao cadastrado.');
    }

    token = (body['token'] ?? body['accessToken'] ?? '').toString();
    final rawUser = body['usuario'] ?? body['user'] ?? body['data'] ?? body;

    if (rawUser is! Map) {
      throw ApiException('Erro');
    }

    return Usuario.fromJson(Map<String, dynamic>.from(rawUser));
  }

  Future<List<Livro>> listarLivros() async {
    final response = await http.get(_uri('/livros/listar'), headers: _headers);
    final body = _decode(response);
    return _asList(body, ['livros', 'data'])
        .whereType<Map>()
        .map((e) => Livro.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Noticia>> listarNoticias() async {
    final response = await http.get(_uri('/noticias/listar'), headers: _headers);
    final body = _decode(response);
    return _asList(body, ['noticias', 'data'])
        .whereType<Map>()
        .map((e) => Noticia.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Emprestimo>> listarEmprestimos() async {
    final response = await http.get(_uri('/emprestimos/listar'), headers: _headers);
    final body = _decode(response);
    return _asList(body, ['emprestimos', 'data'])
        .whereType<Map>()
        .map((e) => Emprestimo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<FilaItem>> listarFila() async {
    final response = await http.get(_uri('/fila/listar'), headers: _headers);
    final body = _decode(response);
    return _asList(body, ['fila', 'data'])
        .whereType<Map>()
        .map((e) => FilaItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> cancelarReserva(int id) async {
    final response = await http.delete(
      _uri('/fila/excluir/$id'),
      headers: _headers,
    );
    _decode(response);
  }
}

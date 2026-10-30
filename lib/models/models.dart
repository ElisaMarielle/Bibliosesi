class Usuario {
  final int? id;
  final String nome;
  final String email;
  final int? rm;

  Usuario({this.id, required this.nome, required this.email, this.rm});

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: _int(json['id']),
        nome: (json['nome'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        rm: _int(json['rm']),
      );
}

class Livro {
  final int? id;
  final String titulo;
  final String descricao;
  final String autor;
  final String genero;
  final String publicacao;
  final String editora;
  final String imagem;
  final String status;

  Livro({
    this.id,
    required this.titulo,
    required this.descricao,
    this.autor = '',
    this.genero = '',
    this.publicacao = '',
    this.editora = '',
    this.imagem = '',
    this.status = 'Livre',
  });

  factory Livro.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] ?? json['situacao'] ?? json['disponibilidade'];
    return Livro(
      id: _int(json['id']),
      titulo: (json['titulo'] ?? '').toString(),
      descricao: (json['descricao'] ?? '').toString(),
      autor: (json['autor'] ?? '').toString(),
      genero: (json['genero'] ?? '').toString(),
      publicacao: (json['publicacao'] ?? '').toString(),
      editora: (json['editora'] ?? '').toString(),
      imagem: (json['imagem'] ?? '').toString(),
      status: rawStatus == null ? 'Livre' : rawStatus.toString(),
    );
  }
}

class Noticia {
  final int? id;
  final String titulo;
  final String autor;
  final String conteudo;
  final String categoria;
  final String data;

  Noticia({
    this.id,
    required this.titulo,
    this.autor = '',
    required this.conteudo,
    this.categoria = '',
    this.data = '',
  });

  factory Noticia.fromJson(Map<String, dynamic> json) => Noticia(
        id: _int(json['id']),
        titulo: (json['titulo'] ?? '').toString(),
        autor: (json['autor'] ?? '').toString(),
        conteudo: (json['conteudo'] ?? '').toString(),
        categoria: (json['categoria'] ?? '').toString(),
        data: (json['data'] ?? '').toString(),
      );
}

class Emprestimo {
  final int? id;
  final String dataEmprestimo;
  final String dataDevolucao;
  final int? usuarioId;
  final int? livroId;
  final String tituloLivro;
  final String status;

  Emprestimo({
    this.id,
    required this.dataEmprestimo,
    required this.dataDevolucao,
    this.usuarioId,
    this.livroId,
    this.tituloLivro = '',
    this.status = 'Em posse',
  });

  factory Emprestimo.fromJson(Map<String, dynamic> json) {
    final livro = json['livro'];
    return Emprestimo(
      id: _int(json['id']),
      dataEmprestimo: (json['data_emprestimo'] ?? json['dataEmprestimo'] ?? '').toString(),
      dataDevolucao: (json['data_devolucao'] ?? json['dataDevolucao'] ?? '').toString(),
      usuarioId: _int(json['usuarioId']),
      livroId: _int(json['livroId']),
      tituloLivro: livro is Map
          ? (livro['titulo'] ?? '').toString()
          : (json['tituloLivro'] ?? '').toString(),
      status: (json['status'] ?? 'Em posse').toString(),
    );
  }
}

class FilaItem {
  final int? id;
  final int? usuarioId;
  final int? livroId;
  final String tituloLivro;
  final int? posicao;

  FilaItem({
    this.id,
    this.usuarioId,
    this.livroId,
    this.tituloLivro = '',
    this.posicao,
  });

  factory FilaItem.fromJson(Map<String, dynamic> json) {
    final livro = json['livro'];
    return FilaItem(
      id: _int(json['id']),
      usuarioId: _int(json['usuarioId']),
      livroId: _int(json['livroId']),
      tituloLivro: livro is Map
          ? (livro['titulo'] ?? '').toString()
          : (json['tituloLivro'] ?? '').toString(),
      posicao: _int(json['posicao'] ?? json['position']),
    );
  }
}

int? _int(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

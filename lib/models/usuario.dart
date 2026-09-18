class Usuario {
  int id;
  String nome;
  String email;
  String senha;
  String telefone;
  String endereco;

  /// 'cliente' ou 'admin'
  String tipo;
  List<String> restricoes;
  bool notificacoes;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    this.telefone = '',
    this.endereco = '',
    this.tipo = 'cliente',
    List<String>? restricoes,
    this.notificacoes = true,
  }) : restricoes = restricoes ?? <String>[];

  bool get isAdmin => tipo == 'admin';
}

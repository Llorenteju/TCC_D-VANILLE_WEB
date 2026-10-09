class Usuario {
  int id;
  String nome;
  String email;
  String senha;
  String telefone;
  String endereco;

  /// Data completa de nascimento (dia, mês e ano).
  /// Pode ser nula para usuários antigos.
  DateTime? dataNascimento;

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
    this.dataNascimento,
    this.tipo = 'cliente',
    List<String>? restricoes,
    this.notificacoes = true,
  }) : restricoes = restricoes ?? <String>[];

  bool get isAdmin => tipo == 'admin';
}

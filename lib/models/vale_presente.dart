class ValePresente {
  final String id;
  final double valor;
  final String codigo;

  /// ativo | usado
  String status;
  final String criadoEm;
  final String destinatario;
  final String mensagem;

  ValePresente({
    required this.id,
    required this.valor,
    required this.codigo,
    this.status = 'ativo',
    required this.criadoEm,
    this.destinatario = '',
    this.mensagem = '',
  });
}

class ValePresente {
  final String id;
  final double valor;
  final String codigo;

  /// ativo | usado
  String status;

  final String criadoEm;
  final String destinatario;
  final String mensagem;

  /// E-mail do cliente que comprou o vale.
  /// Opcional para manter compatibilidade com os vales já cadastrados.
  final String compradorEmail;

  ValePresente({
    required this.id,
    required this.valor,
    required this.codigo,
    this.status = 'ativo',
    required this.criadoEm,
    this.destinatario = '',
    this.mensagem = '',
    this.compradorEmail = '',
  });
}

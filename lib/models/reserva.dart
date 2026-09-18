class Reserva {
  final String id;
  final String nome;
  final String email;
  final String telefone;

  /// Formato AAAA-MM-DD (igual ao input date do HTML).
  final String data;
  final String horario;
  final int pessoas;
  final String preferencias;
  final String observacoes;

  /// solicitada | confirmada | cancelada | finalizada
  String status;

  Reserva({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.data,
    required this.horario,
    required this.pessoas,
    this.preferencias = '',
    this.observacoes = '',
    this.status = 'solicitada',
  });

  String get dataBr {
    final partes = data.split('-');
    if (partes.length != 3) return data;
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }
}

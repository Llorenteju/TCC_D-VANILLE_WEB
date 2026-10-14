class ItemPedido {
  final String produtoId;
  final String nome;
  final double preco;
  final int qtd;

  ItemPedido({
    required this.produtoId,
    required this.nome,
    required this.preco,
    this.qtd = 1,
  });

  double get subtotal => preco * qtd;
}

class Pedido {
  final String id;
  final String clienteEmail;
  final List<ItemPedido> itens;
  final double total;

  /// Data formatada como dd/MM/yyyy HH:mm.
  final String data;

  /// recebido | em preparação | pronto | finalizado
  String status;

  /// 'caixa' ou 'retirar'.
  final String modo;

  /// Número da mesa para pedidos feitos pelo QR Code.
  /// Nulo para pedidos comuns do site.
  final String? mesa;

  Pedido({
    required this.id,
    required this.clienteEmail,
    required this.itens,
    required this.total,
    required this.data,
    this.status = 'recebido',
    this.modo = 'caixa',
    this.mesa,
  });

  /// Indica se o pedido foi feito por uma mesa.
  bool get ehPedidoDeMesa => mesa != null && mesa!.trim().isNotEmpty;

  String get resumoItens => itens.map((i) => '${i.qtd}x ${i.nome}').join(', ');
}

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

  /// Data já formatada (dd/MM/yyyy HH:mm), como no protótipo HTML.
  final String data;

  /// recebido | em preparação | pronto | finalizado
  String status;

  /// 'caixa' ou 'retirar'
  final String modo;

  Pedido({
    required this.id,
    required this.clienteEmail,
    required this.itens,
    required this.total,
    required this.data,
    this.status = 'recebido',
    this.modo = 'caixa',
  });

  String get resumoItens =>
      itens.map((i) => '${i.qtd}x ${i.nome}').join(', ');
}

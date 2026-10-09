
/// Representa um item adicionado à comanda de uma mesa.
class ItemComandaMesa {
  final String produtoId;
  final String nome;
  final double preco;
  int quantidade;

  ItemComandaMesa({
    required this.produtoId,
    required this.nome,
    required this.preco,
    this.quantidade = 1,
  });

  double get subtotal => preco * quantidade;
}

/// Representa a comanda digital de uma mesa da D'Vanille.
class ComandaMesa {
  final String id;
  final String mesa;
  final DateTime criadaEm;

  final List<ItemComandaMesa> itens = [];

  /// Estados possíveis: aberta, aguardando atendimento e encerrada.
  String status;

  bool atendimentoSolicitado;

  ComandaMesa({
    required this.id,
    required this.mesa,
    DateTime? criadaEm,
    this.status = 'aberta',
    this.atendimentoSolicitado = false,
  }) : criadaEm = criadaEm ?? DateTime.now();

  int get quantidadeItens => itens.fold(
        0,
        (total, item) => total + item.quantidade,
      );

  double get total => itens.fold(
        0.0,
        (soma, item) => soma + item.subtotal,
      );

  bool get vazia => itens.isEmpty;

  void adicionarItem({
    required String produtoId,
    required String nome,
    required double preco,
    int quantidade = 1,
  }) {
    if (quantidade <= 0) return;

    final existente = itens.where(
      (item) => item.produtoId == produtoId,
    );

    if (existente.isNotEmpty) {
      existente.first.quantidade += quantidade;
    } else {
      itens.add(
        ItemComandaMesa(
          produtoId: produtoId,
          nome: nome,
          preco: preco,
          quantidade: quantidade,
        ),
      );
    }
  }

  void alterarQuantidade(String produtoId, int variacao) {
    final indice = itens.indexWhere(
      (item) => item.produtoId == produtoId,
    );

    if (indice == -1) return;

    final item = itens[indice];
    final novaQuantidade = item.quantidade + variacao;

    if (novaQuantidade <= 0) {
      itens.removeAt(indice);
    } else {
      item.quantidade = novaQuantidade;
    }
  }

  void removerItem(String produtoId) {
    itens.removeWhere(
      (item) => item.produtoId == produtoId,
    );
  }

  void solicitarAtendimento() {
    atendimentoSolicitado = true;
    status = 'aguardando atendimento';
  }
}


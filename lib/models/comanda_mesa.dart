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

  /// Valor total deste item.
  double get subtotal => preco * quantidade;
}

/// Representa a comanda digital de uma mesa da D'Vanille.
class ComandaMesa {
  final String id;
  final String mesa;
  final DateTime criadaEm;

  /// Produtos que ainda não foram enviados como pedido.
  final List<ItemComandaMesa> itens = [];

  /// Estados da comanda:
  /// aberta, aguardando atendimento e encerrada.
  String status;

  /// Indica se o cliente solicitou atendimento.
  bool atendimentoSolicitado;

  ComandaMesa({
    required this.id,
    required this.mesa,
    DateTime? criadaEm,
    this.status = 'aberta',
    this.atendimentoSolicitado = false,
  }) : criadaEm = criadaEm ?? DateTime.now();

  /// Quantidade total de unidades nos itens pendentes.
  int get quantidadeItens => itens.fold(
        0,
        (total, item) => total + item.quantidade,
      );

  /// Valor total dos itens pendentes.
  double get total => itens.fold(
        0.0,
        (soma, item) => soma + item.subtotal,
      );

  /// Indica se não existem itens pendentes.
  bool get vazia => itens.isEmpty;

  /// Indica se a comanda foi encerrada.
  bool get encerrada => status == 'encerrada';

  /// Indica se a comanda pode receber alterações.
  bool get podeEditar => !encerrada;

  /// Adiciona um produto ou incrementa sua quantidade.
  void adicionarItem({
    required String produtoId,
    required String nome,
    required double preco,
    int quantidade = 1,
  }) {
    if (quantidade <= 0 || encerrada) return;

    final indice = itens.indexWhere(
      (item) => item.produtoId == produtoId,
    );

    if (indice != -1) {
      itens[indice].quantidade += quantidade;
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

  /// Altera a quantidade de um produto pendente.
  ///
  /// Se a quantidade chegar a zero, o item será removido.
  void alterarQuantidade(String produtoId, int variacao) {
    if (encerrada || variacao == 0) return;

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

  /// Remove um produto da lista de itens pendentes.
  void removerItem(String produtoId) {
    if (encerrada) return;

    itens.removeWhere(
      (item) => item.produtoId == produtoId,
    );
  }

  /// Registra uma solicitação de atendimento.
  void solicitarAtendimento() {
    if (encerrada) return;

    atendimentoSolicitado = true;
    status = 'aguardando atendimento';
  }

  /// Limpa a solicitação de atendimento.
  void limparSolicitacaoAtendimento() {
    atendimentoSolicitado = false;

    if (status == 'aguardando atendimento') {
      status = 'aberta';
    }
  }
}

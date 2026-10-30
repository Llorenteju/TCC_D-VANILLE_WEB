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

  String status;
  bool atendimentoSolicitado;

  /// Cupom aplicado exclusivamente nesta comanda.
  String? cupomAplicado;

  /// Percentual de desconto aplicado.
  double percentualDesconto;

  ComandaMesa({
    required this.id,
    required this.mesa,
    DateTime? criadaEm,
    this.status = 'aberta',
    this.atendimentoSolicitado = false,
    this.cupomAplicado,
    this.percentualDesconto = 0,
  }) : criadaEm = criadaEm ?? DateTime.now();

  int get quantidadeItens => itens.fold(
        0,
        (total, item) => total + item.quantidade,
      );

  /// Soma dos produtos antes do desconto.
  double get subtotal => itens.fold(
        0.0,
        (soma, item) => soma + item.subtotal,
      );

  /// Valor descontado da comanda.
  double get desconto => subtotal * percentualDesconto;

  /// Total final, já considerando o desconto.
  double get total {
    final valor = subtotal - desconto;
    return valor < 0 ? 0 : valor;
  }

  bool get vazia => itens.isEmpty;

  bool get encerrada => status == 'encerrada';

  bool get podeEditar => !encerrada;

  bool get temCupom => cupomAplicado != null;

  /// Aplica um cupom à comanda.
  void aplicarCupom({
    required String codigo,
    required double percentual,
  }) {
    if (encerrada || itens.isEmpty) return;

    cupomAplicado = codigo;
    percentualDesconto = percentual;
  }

  /// Remove o cupom da comanda.
  void removerCupom() {
    cupomAplicado = null;
    percentualDesconto = 0;
  }

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

  void removerItem(String produtoId) {
    if (encerrada) return;

    itens.removeWhere(
      (item) => item.produtoId == produtoId,
    );
  }

  void solicitarAtendimento() {
    if (encerrada) return;

    atendimentoSolicitado = true;
    status = 'aguardando atendimento';
  }

  void limparSolicitacaoAtendimento() {
    atendimentoSolicitado = false;

    if (status == 'aguardando atendimento') {
      status = 'aberta';
    }
  }
}

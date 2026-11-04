/// Tipos de item que podem entrar no carrinho.
enum TipoItemCarrinho {
  produto,
  valePresente,
}

/// Item do carrinho da D'Vanille.
class ItemCarrinho {
  final String id;
  final String nome;
  final double preco;
  final String imagem;
  final String icon;

  /// Identifica se o item é um produto ou um vale-presente.
  final TipoItemCarrinho tipo;

  /// Nome da pessoa que receberá o vale-presente.
  final String destinatario;

  /// Mensagem personalizada do vale-presente.
  final String mensagem;

  /// Quantidade do item no carrinho.
  int qtd;

  ItemCarrinho({
    required this.id,
    required this.nome,
    required this.preco,
    this.imagem = '',
    this.icon = '🍽️',
    this.tipo = TipoItemCarrinho.produto,
    this.destinatario = '',
    this.mensagem = '',
    this.qtd = 1,
  });

  /// Valor total deste item, considerando a quantidade.
  double get subtotal => preco * qtd;

  /// Informa se o item é um vale-presente.
  bool get ehValePresente => tipo == TipoItemCarrinho.valePresente;
}

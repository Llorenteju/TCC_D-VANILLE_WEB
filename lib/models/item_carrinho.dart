/// Item do carrinho. O id é String porque vale-presentes entram no carrinho
/// com um id próprio ("gift-..."), exatamente como no protótipo HTML.
class ItemCarrinho {
  final String id;
  final String nome;
  final double preco;
  final String imagem;
  final String icon;
  int qtd;

  ItemCarrinho({
    required this.id,
    required this.nome,
    required this.preco,
    this.imagem = '',
    this.icon = '🍽️',
    this.qtd = 1,
  });

  double get subtotal => preco * qtd;
}

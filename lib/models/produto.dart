/// Informações nutricionais por porção (mesmas chaves usadas no HTML).
class Nutricional {
  double calorias;
  double carboidratos;
  double proteinas;
  double gorduras;
  double fibras;
  double acucares;

  Nutricional({
    this.calorias = 0,
    this.carboidratos = 0,
    this.proteinas = 0,
    this.gorduras = 0,
    this.fibras = 0,
    this.acucares = 0,
  });

  /// Mesma ordem de linhas da tabela do protótipo HTML.
  List<List<String>> get linhas => [
        ['Calorias', '${_n(calorias)} kcal'],
        ['Carboidratos', '${_n(carboidratos)} g'],
        ['Proteínas', '${_n(proteinas)} g'],
        ['Gorduras', '${_n(gorduras)} g'],
        ['Fibras', '${_n(fibras)} g'],
        ['Açúcares', '${_n(acucares)} g'],
      ];

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

class Produto {
  int id;
  String nome;

  /// id da categoria: bolos, doces, sobremesas-geladas, bebidas, salgados
  String categoria;
  double preco;
  double? precoAntigo;
  String descricao;
  String imagem;
  String icon;
  List<String> ingredientes;
  List<String> restricoes;
  List<String> alergenicos;
  Nutricional nutricional;
  bool oferta;

  Produto({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.preco,
    required this.descricao,
    this.precoAntigo,
    this.imagem = '',
    this.icon = '🍽️',
    List<String>? ingredientes,
    List<String>? restricoes,
    List<String>? alergenicos,
    Nutricional? nutricional,
    this.oferta = false,
  })  : ingredientes = ingredientes ?? <String>[],
        restricoes = restricoes ?? <String>[],
        alergenicos = alergenicos ?? <String>[],
        nutricional = nutricional ?? Nutricional();

  /// Percentual de desconto exibido na página de ofertas.
  int get descontoPercentual {
    final antigo = precoAntigo;
    if (antigo == null || antigo <= 0) return 0;
    return ((1 - preco / antigo) * 100).round();
  }
}

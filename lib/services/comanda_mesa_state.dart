import 'package:flutter/foundation.dart';

import '../models/comanda_mesa.dart';
import '../models/produto.dart';

class ComandaMesaState extends ChangeNotifier {
  ComandaMesaState._();

  static final ComandaMesaState instance = ComandaMesaState._();

  final Map<String, ComandaMesa> _comandas = {};

  List<ComandaMesa> get comandas => List.unmodifiable(_comandas.values);

  ComandaMesa? comandaDaMesa(String mesa) => _comandas[mesa.trim()];

  ComandaMesa abrirComanda(String mesa) {
    final numeroMesa = mesa.trim();

    if (numeroMesa.isEmpty) {
      throw ArgumentError('Informe uma mesa válida.');
    }

    final existente = _comandas[numeroMesa];

    if (existente != null && existente.status != 'encerrada') {
      return existente;
    }

    final comanda = ComandaMesa(
      id: 'CM-${DateTime.now().microsecondsSinceEpoch}',
      mesa: numeroMesa,
    );

    _comandas[numeroMesa] = comanda;
    notifyListeners();

    return comanda;
  }

  bool _podeEditar(ComandaMesa comanda) {
    return comanda.status != 'encerrada' &&
        comanda.status != 'enviado ao caixa';
  }

  void adicionarProduto({
    required String mesa,
    required Produto produto,
    int quantidade = 1,
  }) {
    if (quantidade <= 0) return;

    final comanda = abrirComanda(mesa);

    if (!_podeEditar(comanda)) return;

    comanda.adicionarItem(
      produtoId: produto.id.toString(),
      nome: produto.nome,
      preco: produto.preco,
      quantidade: quantidade,
    );

    notifyListeners();
  }

  void alterarQuantidade({
    required String mesa,
    required String produtoId,
    required int variacao,
  }) {
    final comanda = _comandas[mesa.trim()];

    if (comanda == null || !_podeEditar(comanda)) return;

    comanda.alterarQuantidade(produtoId, variacao);
    notifyListeners();
  }

  void removerProduto({
    required String mesa,
    required String produtoId,
  }) {
    final comanda = _comandas[mesa.trim()];

    if (comanda == null || !_podeEditar(comanda)) return;

    comanda.removerItem(produtoId);
    notifyListeners();
  }

  void solicitarAtendimento(String mesa) {
    final numeroMesa = mesa.trim();

    if (numeroMesa.isEmpty) return;

    // O cliente pode chamar o garçom mesmo sem pedir produtos.
    final comanda = abrirComanda(numeroMesa);

    if (!_podeEditar(comanda)) return;

    comanda.solicitarAtendimento();
    notifyListeners();
  }

  /// Marca a comanda como enviada ao caixa.
  ///
  /// Retorna false se não existir, estiver vazia, encerrada
  /// ou já tiver sido enviada.
  bool enviarPedidoAoCaixa(String mesa) {
    final numeroMesa = mesa.trim();

    if (numeroMesa.isEmpty) return false;

    final comanda = _comandas[numeroMesa];

    if (comanda == null || comanda.itens.isEmpty || !_podeEditar(comanda)) {
      return false;
    }

    comanda.status = 'enviado ao caixa';
    notifyListeners();

    return true;
  }

  void encerrarComanda(String mesa) {
    final comanda = _comandas[mesa.trim()];

    if (comanda == null) return;

    comanda.status = 'encerrada';
    notifyListeners();
  }
}

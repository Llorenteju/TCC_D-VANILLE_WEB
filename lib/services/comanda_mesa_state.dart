import 'package:flutter/foundation.dart';

import '../models/comanda_mesa.dart';
import '../models/pedido.dart';
import '../models/produto.dart';
import 'app_state.dart';

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
    // A comanda permanece editável até ser encerrada.
    return comanda.status != 'encerrada';
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

    // Ao começar um novo pedido, a comanda volta a ficar aberta.
    comanda.status = 'aberta';

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

    final comanda = abrirComanda(numeroMesa);

    if (!_podeEditar(comanda)) return;

    comanda.solicitarAtendimento();
    notifyListeners();
  }

  /// Registra um novo pedido sem encerrar a comanda da mesa.
  ///
  /// Cada envio cria um Pedido independente no AppState.
  /// Os itens enviados são removidos da lista pendente para
  /// impedir que sejam cobrados novamente no próximo envio.
  bool enviarPedidoAoCaixa(String mesa) {
    final numeroMesa = mesa.trim();

    if (numeroMesa.isEmpty) return false;

    final state = AppState.instance;
    final cliente = state.usuarioLogado;
    final comanda = _comandas[numeroMesa];

    if (cliente == null ||
        comanda == null ||
        comanda.itens.isEmpty ||
        !_podeEditar(comanda)) {
      return false;
    }

    final agora = DateTime.now();

    final dataFormatada = '${agora.day.toString().padLeft(2, '0')}/'
        '${agora.month.toString().padLeft(2, '0')}/'
        '${agora.year} '
        '${agora.hour.toString().padLeft(2, '0')}:'
        '${agora.minute.toString().padLeft(2, '0')}';

    final itensEnviados = comanda.itens
        .map(
          (item) => ItemPedido(
            produtoId: item.produtoId,
            nome: item.nome,
            preco: item.preco,
            qtd: item.quantidade,
          ),
        )
        .toList();

    final totalEnviado = comanda.total;

    final pedido = Pedido(
      id: 'PD-${agora.microsecondsSinceEpoch}',
      clienteEmail: cliente.email,
      itens: itensEnviados,
      total: totalEnviado,
      data: dataFormatada,
      status: 'recebido',
      modo: 'caixa',
      mesa: numeroMesa,
    );

    // Registra este envio como um pedido independente.
    state.pedidos.add(pedido);

    // Limpa somente os itens já enviados, não o histórico de pedidos.
    comanda.itens.clear();

    // Mantém a mesma comanda aberta para novas compras.
    comanda.status = 'aberta';

    state.notifyListeners();
    notifyListeners();

    return true;
  }

  /// Encerra definitivamente a comanda da mesa.
  void encerrarComanda(String mesa) {
    final comanda = _comandas[mesa.trim()];

    if (comanda == null) return;

    comanda.status = 'encerrada';
    notifyListeners();
  }
}

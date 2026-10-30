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

  /// Abre uma comanda para a mesa informada.
  ///
  /// Se já existir uma comanda aberta, ela será reutilizada.
  /// Se a comanda anterior estiver encerrada, uma nova será criada.
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

  /// Verifica se a comanda ainda pode ser modificada.
  bool _podeEditar(ComandaMesa comanda) {
    return comanda.status != 'encerrada';
  }

  /// Adiciona um produto à comanda da mesa.
  void adicionarProduto({
    required String mesa,
    required Produto produto,
    int quantidade = 1,
  }) {
    final numeroMesa = mesa.trim();

    if (numeroMesa.isEmpty || quantidade <= 0) return;

    final comanda = _comandas[numeroMesa];

    // Não cria nem reabre uma comanda encerrada por acidente.
    if (comanda == null || !_podeEditar(comanda)) return;

    comanda.adicionarItem(
      produtoId: produto.id.toString(),
      nome: produto.nome,
      preco: produto.preco,
      quantidade: quantidade,
    );

    // Mantém a comanda aberta enquanto o cliente adiciona itens.
    comanda.status = 'aberta';

    notifyListeners();
  }

  /// Aumenta ou diminui a quantidade de um produto.
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

  /// Remove um produto da comanda.
  void removerProduto({
    required String mesa,
    required String produtoId,
  }) {
    final comanda = _comandas[mesa.trim()];

    if (comanda == null || !_podeEditar(comanda)) return;

    comanda.removerItem(produtoId);

    notifyListeners();
  }

  /// Solicita atendimento para a mesa.
  void solicitarAtendimento(String mesa) {
    final numeroMesa = mesa.trim();

    if (numeroMesa.isEmpty) return;

    final comanda = _comandas[numeroMesa];

    if (comanda == null || !_podeEditar(comanda)) return;

    comanda.solicitarAtendimento();

    notifyListeners();
  }

  /// Registra um pedido independente no AppState sem encerrar
  /// a comanda da mesa.
  ///
  /// Os itens enviados são removidos da lista pendente para evitar
  /// que sejam enviados novamente no próximo pedido.
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

    // Copia os itens pendentes para o novo pedido.
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

    // Cada envio é registrado como um pedido independente.
    state.pedidos.add(pedido);

    // Remove somente os itens enviados.
    // O histórico dos pedidos anteriores permanece disponível.
    comanda.itens.clear();

    // A comanda continua aberta para novos pedidos.
    comanda.status = 'aberta';

    // Atualiza as telas que acompanham os pedidos e a comanda.
    state.notifyListeners();
    notifyListeners();

    return true;
  }

  /// Encerra definitivamente a comanda atual da mesa.
  void encerrarComanda(String mesa) {
    final comanda = _comandas[mesa.trim()];

    if (comanda == null) return;

    comanda.status = 'encerrada';

    notifyListeners();
  }
}

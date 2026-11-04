import 'package:flutter/foundation.dart';

import '../models/comanda_mesa.dart';
import '../models/pedido.dart';
import '../models/produto.dart';
import 'app_state.dart';
import '../data/mock_data.dart';

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
    return comanda.status != 'encerrada';
  }

  void adicionarProduto({
    required String mesa,
    required Produto produto,
    int quantidade = 1,
  }) {
    final numeroMesa = mesa.trim();

    if (numeroMesa.isEmpty || quantidade <= 0) return;

    final comanda = _comandas[numeroMesa];

    if (comanda == null || !_podeEditar(comanda)) return;

    comanda.adicionarItem(
      produtoId: produto.id.toString(),
      nome: produto.nome,
      preco: produto.preco,
      quantidade: quantidade,
    );

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

  /// Verifica se hoje está na semana do aniversário.
  ///
  /// A semana começa na segunda-feira e termina no domingo.
  bool _estaNaSemanaDoAniversario(DateTime nascimento) {
    final hoje = DateTime.now();

    // Ajusta o dia para aniversários em 29 de fevereiro.
    final ultimoDiaDoMes = DateTime(
      hoje.year,
      nascimento.month + 1,
      0,
    ).day;

    final diaAniversario =
        nascimento.day > ultimoDiaDoMes ? ultimoDiaDoMes : nascimento.day;

    final aniversario = DateTime(
      hoje.year,
      nascimento.month,
      diaAniversario,
    );

    final inicioSemana = aniversario.subtract(
      Duration(days: aniversario.weekday - DateTime.monday),
    );

    final fimSemana = inicioSemana.add(const Duration(days: 6));

    final dataHoje = DateTime(hoje.year, hoje.month, hoje.day);

    return !dataHoje.isBefore(inicioSemana) && !dataHoje.isAfter(fimSemana);
  }

  /// Aplica o cupom de aniversário exclusivamente à comanda.
  bool aplicarCupomAniversario(String mesa) {
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

    // Impede reaplicação do mesmo cupom.
    if (comanda.temCupom) return false;

    final nascimento = cliente.dataNascimento;

    if (nascimento == null || !_estaNaSemanaDoAniversario(nascimento)) {
      return false;
    }

    final percentual = cupons['ANIVERSARIO'];

    if (percentual == null) return false;

    comanda.aplicarCupom(
      codigo: 'ANIVERSARIO',
      percentual: percentual,
    );

    notifyListeners();

    return true;
  }

  /// Remove o cupom aplicado à comanda.
  void removerCupom(String mesa) {
    final comanda = _comandas[mesa.trim()];

    if (comanda == null || !_podeEditar(comanda)) return;

    comanda.removerCupom();

    notifyListeners();
  }

  void solicitarAtendimento(String mesa) {
    final numeroMesa = mesa.trim();

    if (numeroMesa.isEmpty) return;

    final comanda = _comandas[numeroMesa];

    if (comanda == null || !_podeEditar(comanda)) return;

    comanda.solicitarAtendimento();

    notifyListeners();
  }

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
    final descontoEnviado = comanda.desconto;
    final cupomEnviado = comanda.cupomAplicado;

    final pedido = Pedido(
      id: 'PD-${agora.microsecondsSinceEpoch}',
      clienteEmail: cliente.email,
      itens: itensEnviados,
      total: totalEnviado,
      desconto: descontoEnviado,
      cupomAplicado: cupomEnviado,
      data: dataFormatada,
      status: 'recebido',
      modo: 'caixa',
      mesa: numeroMesa,
    );

    state.pedidos.add(pedido);

    // Limpa os itens e o cupom após o envio.
    comanda.itens.clear();
    comanda.removerCupom();

    comanda.status = 'aberta';

    state.notifyListeners();
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

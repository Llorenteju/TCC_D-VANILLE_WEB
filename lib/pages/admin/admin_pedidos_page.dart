import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../models/pedido.dart';
import '../../services/app_state.dart';
import '../../services/navigation.dart';
import '../../theme/app_theme.dart';
import 'admin_shell.dart';

class AdminPedidosPage extends StatefulWidget {
  const AdminPedidosPage({super.key});

  @override
  State<AdminPedidosPage> createState() => _AdminPedidosPageState();
}

class _AdminPedidosPageState extends State<AdminPedidosPage> {
  static const List<String> _opcoes = [
    'recebido',
    'em preparação',
    'pronto',
    'finalizado',
  ];

  final TextEditingController _buscaController = TextEditingController();

  String _filtroStatus = 'todos';

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  // ================= CORES =================

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _corTexto => _isDark
      ? Theme.of(context).colorScheme.onSurface
      : DVanilleColors.darkTaupe;

  Color get _corSecundaria =>
      _isDark ? const Color(0xFFCEBFB1) : DVanilleColors.taupe;

  Color get _corBorda =>
      _isDark ? const Color(0xFF5A4D44) : DVanilleColors.line;

  Color get _corSuperficie => Theme.of(context).cardColor;

  Color _corStatus(String status) {
    switch (status) {
      case 'recebido':
        return const Color(0xFF467A96);
      case 'em preparação':
        return const Color(0xFFAD762D);
      case 'pronto':
        return const Color(0xFF43815A);
      case 'finalizado':
        return DVanilleColors.taupe;
      default:
        return DVanilleColors.rose;
    }
  }

  Color _fundoStatus(String status) {
    if (_isDark) {
      switch (status) {
        case 'recebido':
          return const Color(0xFF253F50);
        case 'em preparação':
          return const Color(0xFF4E3925);
        case 'pronto':
          return const Color(0xFF294735);
        case 'finalizado':
          return const Color(0xFF494036);
        default:
          return DVanilleColors.darkCream2;
      }
    }

    switch (status) {
      case 'recebido':
        return const Color(0xFFE7F1F7);
      case 'em preparação':
        return const Color(0xFFFFF1DA);
      case 'pronto':
        return const Color(0xFFE4F2E7);
      case 'finalizado':
        return const Color(0xFFF0EBE5);
      default:
        return DVanilleColors.blush2;
    }
  }

  String _nomeStatus(String status) {
    switch (status) {
      case 'recebido':
        return 'Recebido';
      case 'em preparação':
        return 'Em preparação';
      case 'pronto':
        return 'Pronto';
      case 'finalizado':
        return 'Finalizado';
      default:
        return status;
    }
  }

  // ================= STATUS =================

  Widget _etiquetaStatus(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: _fundoStatus(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _nomeStatus(status),
        style: TextStyle(
          color: _isDark ? Colors.white : _corStatus(status),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _atualizarStatus(Pedido pedido, String novoStatus) {
    if (pedido.status == novoStatus) return;

    AppState.instance.atualizarStatusPedido(
      pedido.id,
      novoStatus,
    );

    showToast(
      'Status do pedido atualizado!',
      '📦',
    );
  }

  Widget _menuStatus(Pedido pedido) {
    return PopupMenuButton<String>(
      tooltip: 'Alterar status do pedido',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (novoStatus) {
        _atualizarStatus(pedido, novoStatus);
      },
      itemBuilder: (context) {
        return _opcoes.map((status) {
          return PopupMenuItem<String>(
            value: status,
            child: Row(
              children: [
                Icon(
                  pedido.status == status
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: _corStatus(status),
                  size: 19,
                ),
                const SizedBox(width: 12),
                Text(_nomeStatus(status)),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 3,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _etiquetaStatus(pedido.status),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _corSecundaria,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  // ================= ESTATÍSTICAS =================

  Widget _cardEstatistica({
    required String titulo,
    required int quantidade,
    required IconData icone,
    required Color cor,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _corSuperficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _corBorda),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            color: cor,
          ),
          Padding(
            padding: const EdgeInsets.all(19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '$quantidade',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: _corTexto,
                        ),
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isDark
                            ? DVanilleColors.darkCream2
                            : DVanilleColors.blush2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icone,
                        color: cor,
                        size: 23,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  titulo,
                  style: TextStyle(
                    color: _corTexto,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumoPedidos(
    double largura,
    List<Pedido> pedidos,
  ) {
    final estatisticas = [
      (
        'Recebidos',
        pedidos.where((p) => p.status == 'recebido').length,
        Icons.inbox_outlined,
        const Color(0xFF679AB2),
      ),
      (
        'Em preparação',
        pedidos.where((p) => p.status == 'em preparação').length,
        Icons.restaurant_outlined,
        const Color(0xFFC69A56),
      ),
      (
        'Prontos',
        pedidos.where((p) => p.status == 'pronto').length,
        Icons.check_circle_outline_rounded,
        const Color(0xFF74A381),
      ),
      (
        'Finalizados',
        pedidos.where((p) => p.status == 'finalizado').length,
        Icons.inventory_2_outlined,
        DVanilleColors.rose,
      ),
    ];

    final int colunas;

    if (largura >= 980) {
      colunas = 4;
    } else if (largura >= 480) {
      colunas = 2;
    } else {
      colunas = 1;
    }

    const espacamento = 16.0;

    final larguraCard = (largura - espacamento * (colunas - 1)) / colunas;

    return Wrap(
      spacing: espacamento,
      runSpacing: espacamento,
      children: estatisticas.map((item) {
        return SizedBox(
          width: larguraCard,
          child: _cardEstatistica(
            titulo: item.$1,
            quantidade: item.$2,
            icone: item.$3,
            cor: item.$4,
          ),
        );
      }).toList(),
    );
  }

  // ================= PESQUISA E FILTRO =================

  Widget _campoBusca() {
    return TextField(
      controller: _buscaController,
      onChanged: (_) => setState(() {}),
      style: TextStyle(
        color: _corTexto,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'Pesquisar número, cliente ou produto...',
        hintStyle: TextStyle(
          color: _corSecundaria,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: DVanilleColors.rose,
        ),
        suffixIcon: _buscaController.text.isNotEmpty
            ? IconButton(
                tooltip: 'Limpar pesquisa',
                onPressed: () {
                  setState(() {
                    _buscaController.clear();
                  });
                },
                icon: const Icon(
                  Icons.close_rounded,
                  size: 19,
                ),
              )
            : null,
        filled: true,
        fillColor: _corSuperficie,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _corBorda),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _corBorda),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: DVanilleColors.rose,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _campoFiltroStatus() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: _corSuperficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _corBorda),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_list_rounded,
            color: DVanilleColors.rose,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filtroStatus,
                isExpanded: true,
                dropdownColor: _corSuperficie,
                style: TextStyle(
                  color: _corTexto,
                  fontSize: 14,
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'todos',
                    child: Text('Todos os status'),
                  ),
                  ..._opcoes.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_nomeStatus(status)),
                    );
                  }),
                ],
                onChanged: (valor) {
                  if (valor == null) return;
                  setState(() {
                    _filtroStatus = valor;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barraFiltros(double largura) {
    if (largura < 690) {
      return Column(
        children: [
          _campoBusca(),
          const SizedBox(height: 12),
          _campoFiltroStatus(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _campoBusca(),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: _campoFiltroStatus(),
        ),
      ],
    );
  }

  void _limparFiltros() {
    setState(() {
      _buscaController.clear();
      _filtroStatus = 'todos';
    });
  }

  // ================= DETALHES DO PEDIDO =================

  Widget _linhaInformacao(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              titulo,
              style: TextStyle(
                color: _corSecundaria,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(
                color: _corTexto,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verDetalhes(Pedido pedido) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Pedido ${pedido.id}',
            style: const TextStyle(
              fontFamily: 'CreamCake',
              fontSize: 32,
              color: DVanilleColors.darkTaupe,
            ),
          ),
          content: SizedBox(
            width: 510,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _linhaInformacao(
                    'Cliente',
                    pedido.clienteEmail.isEmpty
                        ? 'Não informado'
                        : pedido.clienteEmail,
                  ),
                  _linhaInformacao(
                    'Horário',
                    pedido.data,
                  ),
                  const SizedBox(height: 5),
                  _etiquetaStatus(pedido.status),
                  const SizedBox(height: 18),
                  Divider(color: _corBorda),
                  const SizedBox(height: 12),
                  Text(
                    'Itens do pedido',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _corTexto,
                    ),
                  ),
                  const SizedBox(height: 13),
                  ...pedido.itens.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 13,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.qtd}x ${item.nome}',
                              style: TextStyle(
                                color: _corTexto,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            money(item.preco * item.qtd),
                            style: TextStyle(
                              color: _corTexto,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Divider(color: _corBorda),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total do pedido',
                        style: TextStyle(
                          color: _corTexto,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        money(pedido.total),
                        style: TextStyle(
                          color: _corTexto,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // ================= TABELA DESKTOP =================

  Widget _tituloColuna(String titulo) {
    return Text(
      titulo,
      style: TextStyle(
        color: _corSecundaria,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _cabecalhoTabela() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      color: _isDark ? DVanilleColors.darkCream2 : DVanilleColors.cream2,
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: _tituloColuna('NÚMERO'),
          ),
          Expanded(
            flex: 3,
            child: _tituloColuna('CLIENTE'),
          ),
          Expanded(
            flex: 4,
            child: _tituloColuna('PRODUTOS'),
          ),
          SizedBox(
            width: 115,
            child: _tituloColuna('TOTAL'),
          ),
          SizedBox(
            width: 160,
            child: _tituloColuna('HORÁRIO'),
          ),
          SizedBox(
            width: 195,
            child: _tituloColuna('STATUS'),
          ),
          SizedBox(
            width: 70,
            child: Center(
              child: _tituloColuna('VER'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaTabela(Pedido pedido) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _verDetalhes(pedido),
            hoverColor:
                _isDark ? const Color(0xFF42362E) : const Color(0xFFFFF3F0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 105,
                    child: Text(
                      pedido.id,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _corTexto,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        pedido.clienteEmail.isEmpty
                            ? 'Não informado'
                            : pedido.clienteEmail,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: _corTexto,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Tooltip(
                        message: pedido.resumoItens,
                        child: Text(
                          pedido.resumoItens,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _corTexto,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 115,
                    child: Text(
                      money(pedido.total),
                      style: TextStyle(
                        color: _corTexto,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: Text(
                      pedido.data,
                      style: TextStyle(
                        fontSize: 12,
                        color: _corSecundaria,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 195,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _menuStatus(pedido),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: IconButton(
                      tooltip: 'Ver detalhes',
                      onPressed: () {
                        _verDetalhes(pedido);
                      },
                      icon: const Icon(
                        Icons.visibility_outlined,
                        color: DVanilleColors.rose,
                        size: 21,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          color: _corBorda,
        ),
      ],
    );
  }

  Widget _tabelaPedidos(List<Pedido> pedidos) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraTabela =
            constraints.maxWidth < 1160 ? 1160.0 : constraints.maxWidth;

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _corSuperficie,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _corBorda),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: larguraTabela,
              child: Column(
                children: [
                  _cabecalhoTabela(),
                  for (final pedido in pedidos) _linhaTabela(pedido),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= CARDS MOBILE =================

  Widget _cardPedidoMobile(Pedido pedido) {
    final quantidadeItens = pedido.itens.fold<int>(
      0,
      (total, item) => total + item.qtd,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _corSuperficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _corBorda),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${pedido.id}',
                  style: TextStyle(
                    color: _corTexto,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _menuStatus(pedido),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            pedido.clienteEmail.isEmpty
                ? 'Cliente não informado'
                : pedido.clienteEmail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _corSecundaria,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 15),
          Divider(color: _corBorda),
          const SizedBox(height: 12),
          Text(
            pedido.resumoItens,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _corTexto,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$quantidadeItens itens · ${pedido.data}',
            style: TextStyle(
              color: _corSecundaria,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  money(pedido.total),
                  style: TextStyle(
                    color: _corTexto,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _verDetalhes(pedido);
                },
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 19,
                ),
                label: const Text('Ver detalhes'),
                style: TextButton.styleFrom(
                  foregroundColor: DVanilleColors.rose,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= LISTA VAZIA =================

  Widget _mensagemListaVazia(bool existemPedidos) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 44,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: _corSuperficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _corBorda),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 44,
            color: DVanilleColors.rose,
          ),
          const SizedBox(height: 14),
          Text(
            existemPedidos
                ? 'Nenhum pedido encontrado'
                : 'Nenhum pedido registrado',
            style: TextStyle(
              color: _corTexto,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            existemPedidos
                ? 'Tente outra pesquisa ou altere o filtro.'
                : 'Os pedidos aparecerão aqui quando forem realizados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _corSecundaria,
              fontSize: 13,
            ),
          ),
          if (existemPedidos) ...[
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _limparFiltros,
              icon: const Icon(
                Icons.filter_alt_off_outlined,
              ),
              label: const Text('Limpar filtros'),
            ),
          ],
        ],
      ),
    );
  }

  // ================= TELA PRINCIPAL =================

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final todosPedidos = state.pedidos;

        final busca = _buscaController.text.trim().toLowerCase();

        final pedidosFiltrados = todosPedidos.reversed.where((pedido) {
          final correspondeBusca = busca.isEmpty ||
              pedido.id.toLowerCase().contains(busca) ||
              pedido.clienteEmail.toLowerCase().contains(busca) ||
              pedido.resumoItens.toLowerCase().contains(busca);

          final correspondeStatus =
              _filtroStatus == 'todos' || pedido.status == _filtroStatus;

          return correspondeBusca && correspondeStatus;
        }).toList();

        return AdminShell(
          titulo: 'Pedidos',
          rotaAtual: Routes.adminPedidos,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final largura = constraints.maxWidth;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SUBTÍTULO
                  Text(
                    'Acompanhe e gerencie os pedidos da cafeteria.',
                    style: TextStyle(
                      fontSize: 14,
                      color: _corSecundaria,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // CARDS DE ESTATÍSTICAS
                  _resumoPedidos(
                    largura,
                    todosPedidos,
                  ),

                  const SizedBox(height: 27),

                  // PESQUISA E FILTROS
                  _barraFiltros(largura),

                  const SizedBox(height: 17),

                  // CONTADOR DE RESULTADOS
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: _corSecundaria,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${pedidosFiltrados.length} de '
                          '${todosPedidos.length} pedidos',
                          style: TextStyle(
                            color: _corSecundaria,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // LISTAGEM RESPONSIVA
                  if (pedidosFiltrados.isEmpty)
                    _mensagemListaVazia(
                      todosPedidos.isNotEmpty,
                    )
                  else if (largura >= 700)
                    _tabelaPedidos(pedidosFiltrados)
                  else
                    Column(
                      children:
                          pedidosFiltrados.map(_cardPedidoMobile).toList(),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
